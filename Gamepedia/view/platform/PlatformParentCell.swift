//
//  PlatformParentCell.swift
//  Gamepedia
//
//  Created by Dzaky on 16/11/21.
//

import Foundation
import UIKit

class PlatformParentCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.clipsToBounds = false
    }
    
    func setBanner(for parentPlatform: ParentPlatform) {
        view.clipsToBounds = true
        
        title.text = parentPlatform.name
        title.clipsToBounds = true
        
        image.sd_setImage(
            with: URL(string: parentPlatform.platforms[0].imageBackground),
            placeholderImage: UIImage(systemName: "photo"))
    }
    
}
