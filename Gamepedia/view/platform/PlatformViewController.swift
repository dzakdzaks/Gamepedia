//
//  PlatformViewController.swift
//  Gamepedia
//
//  Created by Dzaky on 16/11/21.
//

import UIKit
import RxSwift

class PlatformViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var platformParentCollection: UICollectionView!
    @IBOutlet weak var platformParentLoading: UIActivityIndicatorView!
    @IBOutlet weak var platformParentIndicator: UIPageControl!
    @IBOutlet weak var platformParentTop: NSLayoutConstraint!
    @IBOutlet weak var platformParentHeight: NSLayoutConstraint!
    @IBOutlet weak var platformCollection: UICollectionView!
    @IBOutlet weak var platformLoading: UIActivityIndicatorView!
    @IBOutlet weak var platformHeight: NSLayoutConstraint!
    
    var viewModel: PlatformViewModel!
    
    private var defaultPlatformParentImage: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        observeState()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore the navigation bar to default
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewDidLayoutSubviews() {
        changeCollectionHeight()
    }
    
}

extension PlatformViewController {
    
    private func setup() {
        platformParentCollection?.tag = 0
        platformCollection?.tag = 1
        scrollView?.tag = 2
        
        platformParentHeight.constant = defaultPlatformParentImage
    }
    
    private func changeCollectionHeight() {
        if platformCollection.contentSize.height > platformHeight.constant {
            platformHeight.constant = platformCollection.contentSize.height
        }
    }
    
    private func observeState() {
        viewModel.onSelectedItem.observe(on: MainScheduler.instance)
            .subscribe { event in
                self.platformCollection?.reloadData()
            }.disposed(by: viewModel.disposeBag)
    }
    
}


extension PlatformViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            let count = viewModel.platformParent.count
            platformParentIndicator.numberOfPages = count
            return count
        } else {
            return viewModel.platform.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let platformParentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parentPlatformCell", for: indexPath) as! PlatformParentCell
            let parentPlatform = viewModel.platformParent[indexPath.row]
            platformParentCell.tag = indexPath.row
            platformParentCell.imageHeight.constant = defaultPlatformParentImage
            platformParentCell.setBanner(for: parentPlatform)
            return platformParentCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "platformCell", for: indexPath) as! SimpleCell
            cell.setPlatform(for: viewModel.platform[indexPath.row])
            return cell
        }
    }
    
}

extension PlatformViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.bounds.width
        var height = collectionView.bounds.height
        if collectionView.tag == 0 {
            return CGSize(width: width, height: height)
        } else {
            width = width / 2 - 20
            height = width
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 0 {
            return 0
        } else {
            return 20
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            platformParentIndicator?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            viewModel.setSelectedItem(position: platformParentCollection.getCurrentPosition())
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
            let index = scrollView.contentOffset.x / witdh
            let roundedIndex = round(index)
            platformParentIndicator?.currentPage = Int(roundedIndex)
        }
        
        if scrollView.tag == 2 {
            let offsetY = scrollView.contentOffset.y
            if offsetY <= 0 {
                
                let platformParentCell = platformParentCollection?.cellForItem(at: platformParentCollection.getCurrentIndexPath()) as! PlatformParentCell
                platformParentCell.imageTop.constant = offsetY
                platformParentCell.imageHeight.constant = platformParentHeight.constant - offsetY
                
            }
            
            if offsetY > defaultPlatformParentImage - 50 {
                navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                navigationController?.navigationBar.shadowImage = nil
            } else {
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIImage()
                navigationController?.navigationBar.isTranslucent = true
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            platformParentIndicator?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            let data = viewModel.platform[indexPath.row]
            guard let controller = R.storyboard.main.listGame() else { return }
            let vm = GameViewModel(platformId: String(data.id), platformName: data.name)
            controller.viewModel = vm
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

