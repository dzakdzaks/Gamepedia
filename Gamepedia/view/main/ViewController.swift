//
//  ViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 15/09/21.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    let searchController = UISearchController()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let dataCellIdentifier = "DataCell"
   
    private var gamesSearches: [Game] = []
    private var selectedGameRow: Int? = nil
    
    private var searchKey: String = ""
    private var ordering: String = ""
    private var page: Int = 1
    
    private var isLoadMore: Bool = false
    
    var searchTimer: Timer?
    
    private let footerView = UIActivityIndicatorView(style: .large)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
    
        setup()
        
        getData(isFromLoadMore: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView?.reloadData()
    }
    
    private func setup() {

        title = "Gamepedia"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Games"
        
        navigationItem.searchController = searchController
                
        definesPresentationContext = true

                        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order by", style: .plain, target: self, action: #selector(showOrderByMenu(sender:)))
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        loadingIndicator.hidesWhenStopped = true
        
        collectionView?.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
    }
    
    private func getData(isFromLoadMore: Bool) {
        if isFromLoadMore {
            isLoadMore = true
            footerView.startAnimating()
        } else {
            gamesSearches.removeAll()
            collectionView?.reloadData()
            loadingIndicator.startAnimating()
        }
        getGames(searchKey: searchKey, ordering: ordering, page: String(page), pageSize: "10", onSuccess: { games in
            DispatchQueue.main.async {
                if isFromLoadMore {
                    self.isLoadMore = false
                    self.footerView.stopAnimating()
                    self.gamesSearches.insert(contentsOf: games.games, at: self.gamesSearches.count)
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.gamesSearches.insert(contentsOf: games.games, at: 0)
                }
                self.collectionView?.reloadData()
            }
        }, onFailure: { msg in
            DispatchQueue.main.async {
                if isFromLoadMore {
                    self.isLoadMore = false
                    self.footerView.stopAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
                print(msg)
            }
        })
    }
    
    @objc private func showOrderByMenu(sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let orderByList = generateOrderBy()

        for item in orderByList {
            if item.value == "Clear" {
                alert.addAction(.init(title: item.value, style: .destructive) { action in
                    self.ordering = ""
                    self.page = 1
                    self.getData(isFromLoadMore: false)
                })
            } else {
                alert.addAction(.init(title: item.value, style: .default) { action in
                    if let index = alert.actions.firstIndex(of: action) {
                        self.ordering = orderByList[index].key
                        self.page = 1
                        self.getData(isFromLoadMore: false)
                    }
                })
            }
        }
        alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
            
        })
        
        present(alert, animated: true)
    }
}

extension ViewController: GameDetailDelegate {
    func onDataChanged(_ game: Game) {
        guard let index = selectedGameRow else {
            return
        }
        gamesSearches[index] = game
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gamesSearches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataCellIdentifier, for: indexPath) as! GameCollectionViewCell
            
        let game = gamesSearches[indexPath.row]
                            
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
        cell.labelReleaseDate.text = game.getReleaseDate()
        
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
                   let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                   footer.addSubview(footerView)
                   footerView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
                   return footer
               }
        return UICollectionReusableView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endScrolling = (scrollView.contentOffset.y + scrollView.frame.size.height)

        if !isLoadMore && endScrolling >= scrollView.contentSize.height {
            page += 1
            getData(isFromLoadMore: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGameRow = indexPath.row
        guard let vc = storyboard?.instantiateViewController(identifier: "DetailGame") as? DetailViewController else { return }
        
        guard let gameSelectedRow = selectedGameRow else { return }
        vc.game = gamesSearches[gameSelectedRow]
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }

        if searchKey != searchText {
            self.searchTimer?.invalidate()
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                DispatchQueue.global(qos: .userInteractive).async {
                    DispatchQueue.main.async {
                        self.searchKey = searchText
                        self.getData(isFromLoadMore: false)
                    }
                }
            }
        }
    }
}

class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
