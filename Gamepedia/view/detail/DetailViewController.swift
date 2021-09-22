//
//  DetailViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 20/09/21.
//

import UIKit
import SDWebImage

protocol GameDetailDelegate: AnyObject {
    func onDataChanged(_ game: Game)
}

class DetailViewController: UIViewController {
    
    var game: Game!
    
    weak var delegate: GameDetailDelegate?
    
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
    @IBOutlet weak var labelAgeRating: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var constrainImageTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    
    private var defaultHeightImage: CGFloat = 233
    
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
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        indicator.hidesWhenStopped = true
        scrollview.delegate = self
        
        defaultHeightImage = UIScreen.main.bounds.width / 2
        constraintImageHeight.constant = defaultHeightImage
    }
    
    private func callDataDetail() {
        
        if game.descriptionRaw == "-" {
            runTaskDetail(gameId: String(game.id))
        } else {
            setupData()
        }
    }
    
    private func runTaskDetail(gameId: String) {
        indicator.startAnimating()
        getDetailGame(gameId: gameId, onSuccess: { game in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.game?.descriptionRaw = game.descriptionRaw
                self.delegate?.onDataChanged(self.game)
                self.setupData()
            }
        }, onFailure: { msg in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                print(msg)
            }
        })
    }
    
    private func setupData() {
        //        let transformer = SDImageResizingTransformer(size: CGSize(width: imageGame.bounds.width * 1.5, height: imageGame.bounds.height * 1.5), scaleMode: .aspectFill)
        
        //        imageGame.sd_setImage(
        //            with: game.getImageURL(),
        //            placeholderImage: UIImage(systemName: "photo"),
        //            context: [.imageTransformer: transformer])
        
        
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
        
        
        labelReleaseDate.text = game.getReleaseDate()
        
        labelAgeRating.text = game.esrbRating?.name
        
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollview.contentOffset.y
    
        if offsetY <= 0 {
            constrainImageTop.constant = offsetY
    
            
//            let output = defaultHeightImage - offsetY
//            let halfScreenHeight = view.frame.height / 2
//            let height = output > halfScreenHeight ? halfScreenHeight : output
            
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
