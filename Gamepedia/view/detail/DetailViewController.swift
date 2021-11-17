//
//  DetailViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 20/09/21.
//

import UIKit
import SDWebImage
import RxSwift

class DetailViewController: UIViewController {
    
    var viewModel: GameViewModel!
    var favoriteViewModel: FavoriteViewModel!
    
    var isFromLocal: Bool!
    
    var game: Game!
    var favoriteGame: LocalGameModel!
    
    private var index = -1
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var imageGame: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var layerRating: UIView!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var containerPlatform: UIView!
    @IBOutlet weak var titlePlatform: UILabel!
    @IBOutlet weak var labelPlatform: UILabel!
    @IBOutlet weak var constraintLabelPlatformBottom: NSLayoutConstraint!
    @IBOutlet weak var containeGenre: UIView!
    @IBOutlet weak var titleGenre: UILabel!
    @IBOutlet weak var labelGenre: UILabel!
    @IBOutlet weak var constraintLabelGenreBottom: NSLayoutConstraint!
    @IBOutlet weak var labelReleaseDate: UILabel!
    @IBOutlet weak var constraintLabelReleaseDateBottom: NSLayoutConstraint!
    @IBOutlet weak var labelAgeRating: UILabel!
    @IBOutlet weak var constraintLabelAgeRatingBottom: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var constrainImageTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    @IBOutlet weak var labelDeveloper: UILabel!
    @IBOutlet weak var constraintLabelDeveloperBottom: NSLayoutConstraint!
    @IBOutlet weak var labelPublisher: UILabel!
    @IBOutlet weak var constraintLabelPublisherBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonFavorite: UIButton!
    
    private var defaultHeightImage: CGFloat = 233
    
    private lazy var gameProvider: GameProvider = { return GameProvider() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isFromLocal {
            setup()
            callDataDetail()
            observeState()
        } else {
            setupLocal()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.transparentNavigation()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isFromLocal {
            let transformer = SDImageResizingTransformer(size: CGSize(width: imageGame.bounds.width * 1.5, height: imageGame.bounds.height * 1.5), scaleMode: .aspectFill)
            
            imageGame.sd_setImage(
                with: game.getImageURL(),
                placeholderImage: UIImage(systemName: "photo"),
                context: [.imageTransformer: transformer])
        } else {
            let transformer = SDImageResizingTransformer(size: CGSize(width: imageGame.bounds.width * 1.5, height: imageGame.bounds.height * 1.5), scaleMode: .aspectFill)
            
            imageGame.sd_setImage(
                with: favoriteGame.getImageURL(),
                placeholderImage: UIImage(systemName: "photo"),
                context: [.imageTransformer: transformer])
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.defaultNavigation()
        super.viewWillDisappear(animated)
    }
    
    private func setup() {
        guard let indexItem = viewModel.selectedGameRow else {
            return
        }
        index = indexItem
        game = viewModel.gamesSearches[index]
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        indicator.hidesWhenStopped = true
        scrollview.delegate = self
        
        defaultHeightImage = UIScreen.main.bounds.width / 2
        constraintImageHeight.constant = defaultHeightImage
        
        gameProvider.isGameAlreadyFavorited(gameId: game.id) { isAlreadyFavorited in
            DispatchQueue.main.async {
                if isAlreadyFavorited {
                    self.buttonFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    self.buttonFavorite.setImage(UIImage(systemName: "star"), for: .normal)
                }
            }
        }
    }
    
    private func callDataDetail() {
        if game.descriptionRaw == "-" {
            callData(gameId: String(game.id))
        } else {
            setupData()
        }
    }
    
    private func callData(gameId: String) {
        viewModel.getGameDetail(gameId: gameId)
    }
    
    private func observeState() {
        viewModel.detailstate.observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let state = event.element else {return}
                switch state {
                case .loading:
                    self.indicator.startAnimating()
                case .idle:
                    break
                case let .complete(data):
                    self.indicator.stopAnimating()
                    self.viewModel.gamesSearches[self.index] = data
                    self.game = data
                    self.setupData()
                case let .error(msg):
                    self.indicator.stopAnimating()
                    self.presentToast(message: msg.localizedDescription, timeInterval: 2, finishAfterRemove: false)
                    print(msg)
                }
            }
        .disposed(by: viewModel.disposeBag)
    }
    
    private func setupData() {
        
        buttonFavorite.addTarget(self, action: #selector(favoriteButtonClicked(sender:)), for: .touchUpInside)
        
        labelName.text = game.name
        
        labelRating.text = "\(String(describing: game.rating!)) / \(String(describing: game.ratingTop!))"
        
        labelDesc.text = game.descriptionRaw
        
        var platforms = Array<String>()
        game.parentPlatforms?.forEach { item in
            platforms.append(item.platform.name)
        }
        
        let platformsString = platforms.joined(separator: ", ")
        
        var genres = Array<String>()
        game.genres?.forEach{ item in
            genres.append(item.name)
        }
        
        let genresString = genres.joined(separator: ", ")
        
        if platformsString.count >= genresString.count {
            constraintLabelGenreBottom?.isActive = false
        } else {
            constraintLabelPlatformBottom?.isActive = false
        }
        
        labelPlatform.text = platformsString
        
        labelGenre.text = genresString
        
        
        if game.getReleaseDate().count >= game.esrbRating?.name.count ?? 0 {
            constraintLabelAgeRatingBottom?.isActive = false
        } else {
            constraintLabelReleaseDateBottom?.isActive = false
        }
        
        labelReleaseDate.text = game.getReleaseDate()
        
        labelAgeRating.text = game.esrbRating != nil ? game.esrbRating?.name : "-"
        
        var developers = Array<String>()
        game.developers?.forEach { item in
            developers.append(item.name)
        }
        
        let developersString = developers.joined(separator: ", ")
        
        var publishers = Array<String>()
        game.publishers?.forEach { item in
            publishers.append(item.name)
        }
        
        let publishersString = publishers.joined(separator: ", ")
        
        if developersString.count >= publishersString.count {
            constraintLabelPublisherBottom?.isActive = false
        } else {
            constraintLabelDeveloperBottom?.isActive = false
        }
        
        labelDeveloper.text = developersString
        
        labelPublisher.text = publishersString
        
    }
    
    private func setupLocal() {
        guard let indexItem = favoriteViewModel.selectedGameRow else {
            return
        }
        index = indexItem
        favoriteGame = favoriteViewModel.games[index]
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        indicator.hidesWhenStopped = true
        scrollview.delegate = self
        
        defaultHeightImage = UIScreen.main.bounds.width / 2
        constraintImageHeight.constant = defaultHeightImage
        
        self.buttonFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
        
        setupDataLocal()
    }
    
    private func setupDataLocal() {
        
        buttonFavorite.addTarget(self, action: #selector(favoriteButtonClicked(sender:)), for: .touchUpInside)
        
        labelName.text = favoriteGame.name
        
        labelRating.text = "\(String(describing: favoriteGame.rating!)) / \(String(describing: favoriteGame.ratingTop!))"
        
        labelDesc.text = favoriteGame.descriptionRaw
        
        if favoriteGame.parentPlatforms?.count ?? 0 >= favoriteGame.genres?.count ?? 0 {
            constraintLabelGenreBottom?.isActive = false
        } else {
            constraintLabelPlatformBottom?.isActive = false
        }
        
        labelPlatform.text = favoriteGame.parentPlatforms
        
        labelGenre.text = favoriteGame.genres
        
        
        if favoriteGame.releaseDate?.count ?? 0 >= favoriteGame.esrbRating?.count ?? 0 {
            constraintLabelAgeRatingBottom?.isActive = false
        } else {
            constraintLabelReleaseDateBottom?.isActive = false
        }
        
        labelReleaseDate.text = favoriteGame.releaseDate
        
        labelAgeRating.text = favoriteGame.esrbRating
        
        if favoriteGame.developers?.count ?? 0 >= favoriteGame.publishers?.count ?? 0 {
            constraintLabelPublisherBottom?.isActive = false
        } else {
            constraintLabelDeveloperBottom?.isActive = false
        }
        
        labelDeveloper.text = favoriteGame.developers
        
        labelPublisher.text = favoriteGame.publishers
    }
    
    //    private func showToast(message : String, seconds: Double, finishAfterRemove: Bool) {
    //        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    //        alert.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
    //        alert.view.layer.cornerRadius = 15
    //
    //        present(alert, animated: true)
    //
    //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
    //            alert.dismiss(animated: true) {
    //                if finishAfterRemove {
    //                    self.navigationController?.popToRootViewController(animated: true)
    //                }
    //            }
    //        }
    //    }
    
    private func presentToast(message: String, timeInterval: TimeInterval, finishAfterRemove: Bool) {
        let toast = ToastViewController(text: message)
        present(toast, animated: true)
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            toast.dismiss(animated: true)
            if finishAfterRemove {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @objc private func favoriteButtonClicked(sender: UIButton) {
        gameProvider.isGameAlreadyFavorited(gameId: !isFromLocal ? game.id : Int(favoriteGame.gameId ?? 0)) { isAlreadyFavorited in
            if isAlreadyFavorited {
                self.gameProvider.deleteFromFavorite(!self.isFromLocal ? self.game.id : Int(self.favoriteGame.gameId ?? 0)) {
                    DispatchQueue.main.async {
                        sender.setImage(UIImage(systemName: "star"), for: .normal)
                        self.presentToast(message: "Removed from favorite", timeInterval: 1, finishAfterRemove: self.isFromLocal)
                    }
                }
            } else {
                if !self.isFromLocal {
                    let localGameModel = LocalGameModel(id: 0, gameId: Int32(self.game.id), name: self.game.name, releaseDate: self.game.getReleaseDate(), backgroundImage: self.game.backgroundImage, rating: self.game.rating, ratingTop: self.game.ratingTop, parentPlatforms: self.labelPlatform.text, genres: self.labelGenre.text, esrbRating: self.labelAgeRating.text, descriptionRaw: self.game.descriptionRaw, developers: self.labelDeveloper.text, publishers: self.labelPublisher.text)
                    self.gameProvider.addToFavorite(localGameModel) {
                        DispatchQueue.main.async {
                            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                            self.presentToast(message: "Added to favorite", timeInterval: 1, finishAfterRemove: false)
                        }
                    }
                }
            }
        }
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollview.contentOffset.y
        
        if offsetY <= 0 {
            constrainImageTop.constant = offsetY
            constraintImageHeight.constant = defaultHeightImage - offsetY
        }
        
        if offsetY > defaultHeightImage - 50 {
            navigationController?.defaultNavigation()
            title = !isFromLocal ? game.name : favoriteGame.name
        } else {
            navigationController?.transparentNavigation()
            title = ""
        }
        
    }
}
