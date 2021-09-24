//
//  ViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 15/09/21.
//

import UIKit
import SDWebImage
import RxSwift

class ViewController: UIViewController {
    
    let searchController = UISearchController()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let footerView = UIActivityIndicatorView(style: .large)
    
    private let dataCellIdentifier = "DataCell"
    
    private let vm: MainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        observeState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView?.reloadData()
    }
    
    private func setup() {
        
        title = "Home"
        navigationItem.title = "Gamepedia"
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Games"
        
        searchController.searchBar
            .rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { query in
                if self.vm.searchKey != self.searchController.searchBar.text {
                    self.vm.searchKey = query
                    self.getData()
                }
            }
            ).disposed(by: vm.disposeBag)
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order by", style: .plain, target: self, action: #selector(showOrderByMenu(sender:)))
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        loadingIndicator.hidesWhenStopped = true
        
        collectionView?.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
    }
    
    private func observeState() {
        vm.state.observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let state = event.element else {return}
                switch state {
                case .loading:
                    if self.vm.isLoadMore {
                        self.footerView.startAnimating()
                    } else {
                        self.vm.gamesSearches.removeAll()
                        self.collectionView?.reloadData()
                        self.loadingIndicator.startAnimating()
                    }
                    break
                case .idle:
                    break
                case .complete:
                    if self.vm.isLoadMore {
                        self.vm.isLoadMore = false
                        self.footerView.stopAnimating()
                    } else {
                        self.loadingIndicator.stopAnimating()
                    }
                    self.collectionView?.reloadData()
                    break
                case let .error(msg):
                    if self.vm.isLoadMore {
                        self.vm.isLoadMore = false
                        self.footerView.stopAnimating()
                    } else {
                        self.loadingIndicator.stopAnimating()
                    }
                    print(msg)
                    break
                }
            }
            .disposed(by: vm.disposeBag)
    }
    
    private func getData() {
        vm.getGames(searchKey: vm.searchKey, ordering: vm.ordering, page: String(vm.page), pageSize: vm.pageSize)
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
                    self.vm.ordering = ""
                    self.vm.page = 1
                    self.getData()
                })
            } else {
                alert.addAction(.init(title: item.value, style: .default) { action in
                    if let index = alert.actions.firstIndex(of: action) {
                        self.vm.ordering = orderByList[index].key
                        self.vm.page = 1
                        self.getData()
                    }
                })
            }
        }
        alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
            
        })
        
        present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.gamesSearches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataCellIdentifier, for: indexPath) as! GameCollectionViewCell
        
        let game = vm.gamesSearches[indexPath.row]
        
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
        
        if !vm.isLoadMore && endScrolling >= scrollView.contentSize.height {
            vm.isLoadMore = true
            vm.page += 1
            getData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vm.selectedGameRow = indexPath.row
        guard let vc = R.storyboard.main.detailGame() else { return }
        vc.vm = vm
        self.navigationController?.pushViewController(vc, animated: true)
        
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
