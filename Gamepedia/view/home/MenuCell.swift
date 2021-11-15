//
//  MenuCell.swift
//  Gamepedia
//
//  Created by Dzaky on 11/11/21.
//

import Foundation
import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    func setMenu(menu: HomeMenu) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        title.text = menu.title
    
        image.image = R.image.dzakdzaks()
    }
}
