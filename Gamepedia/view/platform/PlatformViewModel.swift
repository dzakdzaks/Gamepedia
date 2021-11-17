//
//  PlatformViewModel.swift
//  Gamepedia
//
//  Created by Dzaky on 16/11/21.
//

import Foundation
import RxSwift
import RxRelay

class PlatformViewModel {
    
    private let client: Client = Client()
    let disposeBag: DisposeBag = DisposeBag()
    
    let onSelectedItem = BehaviorRelay<BannerState>(value: .idle)
    
    var platformParent: [ParentPlatform] = []
    var platform: [Platform] = []
    
    init(platformParent: [ParentPlatform], selectedPlatformParent: Int) {
        self.platformParent = platformParent
        platform = self.platformParent[selectedPlatformParent].platforms
        onSelectedItem.accept(.defaultInit(selected: selectedPlatformParent))
    }
    
    func setSelectedItem(position: Int) {
        platform = platformParent[position].platforms
        print("wakwaw \(position)")
        onSelectedItem.accept(.dragged)
    }
    
}
