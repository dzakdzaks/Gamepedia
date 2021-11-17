//
//  HomeViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 11/11/21.
//

import Foundation
import UIKit
import RxSwift

class HomeViewController: UIViewController {
        
    @IBOutlet weak var bannerView: UICollectionView!
    @IBOutlet weak var menuView: UICollectionView!
    @IBOutlet weak var menuViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerIndicator: UIPageControl!
    @IBOutlet weak var bannerLoading: UIActivityIndicatorView!
    
    private let viewModel: HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        observeState()
        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        changeCollectionHeight()
    }
    
}

extension HomeViewController {
    
    private func setup() {
        title = "Home"
        navigationItem.title = "Gamepedia"
        
        bannerView?.tag = 0
        
        menuView.tag = 1
        
    }
    
    private func changeCollectionHeight() {
        menuViewHeight.constant = menuView.contentSize.height
    }
    
    private func observeState() {
        viewModel.parentPlatformState.observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let state = event.element else {return}
                switch state {
                case .loading:
                    self.bannerLoading?.startAnimating()
                    self.viewModel.parentPlatforms.removeAll()
                    self.bannerView?.reloadData()
                case .idle:
                    break
                case .complete:
                    self.bannerLoading?.stopAnimating()
                    self.bannerView?.reloadData()
                    break
                case let .error(msg):
                    self.bannerLoading?.stopAnimating()
                    print(msg)
                    break
                }
            }.disposed(by: viewModel.disposeBag)
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            let count = viewModel.parentPlatforms.count
            bannerIndicator.numberOfPages = count
            return count
        } else {
            return viewModel.homeMenus.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath) as! SimpleCell
            let parentPlatform = viewModel.parentPlatforms[indexPath.row]
            cell.setBannerRounded(for: parentPlatform)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! SimpleCell
            let homeMenu = viewModel.homeMenus[indexPath.row]
            cell.setHomeMenu(for: homeMenu)
            return cell
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.bounds.width
        var height = collectionView.bounds.height
        if collectionView.tag == 0 {
            width = width - 20
            return CGSize(width: width, height: height)
        } else {
            width = width / 2 - 20
            height = width
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            bannerIndicator?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
            let index = scrollView.contentOffset.x / witdh
            let roundedIndex = round(index)
            bannerIndicator?.currentPage = Int(roundedIndex)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        bannerIndicator?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            guard let controller = R.storyboard.main.platform() else { return }
            controller.viewModel = PlatformViewModel(platformParent: viewModel.parentPlatforms, selectedPlatformParent: indexPath.row)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let homeMenu = viewModel.homeMenus[indexPath.row]
            switch homeMenu.id {
            case 1:
                guard let controller = R.storyboard.main.listGame() else { return }
                let vm = GameViewModel()
                controller.viewModel = vm
                navigationController?.pushViewController(controller, animated: true)
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                break
            default:
                // 6
                break
            }
        }
    }
    
}
