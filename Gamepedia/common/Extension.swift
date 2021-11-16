//
//  Extension.swift
//  Gamepedia
//
//  Created by Dzaky on 16/11/21.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func getCurrentPosition() -> Int {
        var visibleRect = CGRect()
        
        visibleRect.origin = contentOffset
        visibleRect.size = bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = indexPathForItem(at: visiblePoint) else { return 0 }
        
        return indexPath.row
    }
    
    func getCurrentIndexPath() -> IndexPath {
        var visibleRect = CGRect()
        
        visibleRect.origin = contentOffset
        visibleRect.size = bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = indexPathForItem(at: visiblePoint) else { return IndexPath() }
        
        return indexPath
    }
    
}
