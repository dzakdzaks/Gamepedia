//
//  BannerCell.swift
//  Gamepedia
//
//  Created by Dzaky on 11/11/21.
//

import Foundation
import UIKit

class SimpleCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    
    func setBanner(for parentPlatform: ParentPlatform) {
        view.clipsToBounds = true
        
        title.text = parentPlatform.name
        title.clipsToBounds = true
        
        image.sd_setImage(
            with: URL(string: parentPlatform.platforms[0].imageBackground),
            placeholderImage: UIImage(systemName: "photo"))
    }
    
    func setBannerRounded(for parentPlatform: ParentPlatform, radius: CGFloat = 10) {
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        
        title.text = parentPlatform.name
        title.clipsToBounds = true
        title.layer.cornerRadius = radius
        
        image.sd_setImage(
            with: URL(string: parentPlatform.platforms[0].imageBackground),
            placeholderImage: UIImage(systemName: "photo"))
    }
    
    
    func setHomeMenu(for homeMenu: HomeMenu) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        title.text = homeMenu.title
        title.clipsToBounds = true
        title.layer.cornerRadius = 10
        
        image.image = R.image.dzakdzaks()
    }
    
    func setPlatform(for platform: Platform) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        title.text = platform.name
        title.clipsToBounds = true
        title.layer.cornerRadius = 10
        
        image.sd_setImage(
            with: URL(string: platform.imageBackground),
            placeholderImage: UIImage(systemName: "photo"))
        
    }
    
    
}
