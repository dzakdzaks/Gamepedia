//
//  BannerCell.swift
//  Gamepedia
//
//  Created by Dzaky on 11/11/21.
//

import Foundation
import UIKit

class BannerCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func setBanner(for parentPlatform: ParentPlatform) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        title.text = parentPlatform.name
        title.clipsToBounds = true
        title.layer.cornerRadius = 10
        
        image.sd_setImage(
            with: URL(string: parentPlatform.platforms[0].imageBackground),
            placeholderImage: UIImage(systemName: "photo"))
    }
    
}
