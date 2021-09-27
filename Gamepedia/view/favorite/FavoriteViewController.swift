//
//  FavoriteViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 27/09/21.
//

import UIKit
import SDWebImage
import RxSwift

class FavoriteViewController: UIViewController {
     
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let dataCellIdentifier = "DataCell"
   
    private let viewModel: FavoriteViewModel = FavoriteViewModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        observeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.getFavoriteGames()
    }
    
    private func setup() {
        title = "Favorite"
        navigationItem.title = "Favorite Games"
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteAllFavorite(sender:)))
    }
    
    private func observeData() {
        viewModel.successFetchData.observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let state = event.element else {return}
                
                if state == true {
                    self.collectionView.reloadData()
                    self.viewModel.successFetchData.accept(false)
                }
            }
            .disposed(by: viewModel.disposeBag)
    }
    
    @objc private func deleteAllFavorite(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Warning", message: "Do you want to delete all favorite games?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.viewModel.gameProvider.deleteAllGame {
                self.viewModel.getFavoriteGames()
            }
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataCellIdentifier, for: indexPath) as! GameCollectionViewCell
        
        let game = viewModel.games[indexPath.row]
        
        cell.view.clipsToBounds = true
        cell.view.layer.cornerRadius = 10
        
        let transformer = SDImageResizingTransformer(size: CGSize(width: cell.backgroundImage.bounds.width * 2.5, height: cell.backgroundImage.bounds.height * 2.5), scaleMode: .aspectFill)
        
        cell.backgroundImage.sd_setImage(
            with: game.getImageURL(),
            placeholderImage: UIImage(systemName: "photo"),
            context: [.imageTransformer: transformer])
        
        cell.layerRating.layer.cornerRadius = 10
        cell.layerRating.backgroundColor = .black.withAlphaComponent(0.5)
        cell.labelRating.text = "\(String(describing: game.rating!)) / \(String(describing: game.ratingTop!))"
        
        cell.labelName.sizeToFit()
        cell.labelName.text = game.name
        
        cell.labelReleaseDate.sizeToFit()
        cell.labelReleaseDate.text = game.releaseDate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Double(collectionView.bounds.width / 2.0 - 15)
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedGameRow = indexPath.row
        guard let controller = R.storyboard.main.detailGame() else { return }
        controller.favoriteViewModel = viewModel
        controller.isFromLocal = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
