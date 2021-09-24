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
    
    var vm: MainViewModel!
    
    var game: Game!
    
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
    
    private var defaultHeightImage: CGFloat = 233
    
    private let client = Client.client()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        callDataDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make the navigation bar background clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let transformer = SDImageResizingTransformer(size: CGSize(width: imageGame.bounds.width * 1.5, height: imageGame.bounds.height * 1.5), scaleMode: .aspectFill)
        
        imageGame.sd_setImage(
            with: game.getImageURL(),
            placeholderImage: UIImage(systemName: "photo"),
            context: [.imageTransformer: transformer])
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore the navigation bar to default
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    private func setup() {
        guard let indexItem = vm.selectedGameRow else {
            return
        }
        index = indexItem
        game = vm.gamesSearches[index]
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        indicator.hidesWhenStopped = true
        scrollview.delegate = self
        
        defaultHeightImage = UIScreen.main.bounds.width / 2
        constraintImageHeight.constant = defaultHeightImage
    }
    
    private func callDataDetail() {
        if game.descriptionRaw == "-" {
            callData(gameId: String(game.id))
        } else {
            setupData()
        }
    }
    
    private func callData(gameId: String) {
        indicator.startAnimating()
        client.getGameDetail(gameId: gameId)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { game in
                    self.vm.gamesSearches[self.index] = game
                    self.game = game
                    self.setupData()
                }, onError: { error in
                    self.indicator.stopAnimating()
                    print(error)
                }, onCompleted: {
                    self.indicator.stopAnimating()
                }, onDisposed: nil
            ).disposed(by: disposeBag)
        
    }
    
    private func setupData() {
        
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
            constraintLabelGenreBottom.isActive = false
        } else {
            constraintLabelPlatformBottom.isActive = false
        }
        
        labelPlatform.text = platformsString
        
        labelGenre.text = genresString
        
        
        if game.getReleaseDate().count >= game.esrbRating?.name.count ?? 0 {
            constraintLabelAgeRatingBottom.isActive = false
        } else {
            constraintLabelReleaseDateBottom.isActive = false
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
            constraintLabelPublisherBottom.isActive = false
        } else {
            constraintLabelDeveloperBottom.isActive = false
        }
        
        labelDeveloper.text = developersString
        
        labelPublisher.text = publishersString
        
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
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
            title = game.name
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            title = ""
        }
        
    }
}
