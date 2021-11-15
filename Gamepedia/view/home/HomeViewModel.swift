//
//  HomeViewModel.swift
//  Gamepedia
//
//  Created by Dzaky on 12/11/21.
//

import Foundation
import RxSwift
import RxRelay

class HomeViewModel {
    
    private let client: Client = Client()
    let disposeBag: DisposeBag = DisposeBag()
    
    let parentPlatformState = BehaviorRelay<ResultState<[ParentPlatform]>>(value: .idle)
    
    var parentPlatforms: [ParentPlatform] = []
    var homeMenus: [HomeMenu] = generateHomeMenu()
    
    init() {
        getParentPlatforms()
    }
    
    func getParentPlatforms() {
        self.parentPlatformState.accept(.loading)
        client.getParentPlatforms()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                if !self.parentPlatforms.isEmpty {
                    self.parentPlatforms.removeAll()
                }
                self.parentPlatforms.append(contentsOf: data.results)
                self.parentPlatformState.accept(.complete(data: data.results))
            }, onError: { error in
                self.parentPlatformState.accept(.error(msg: error.localizedDescription))
            }, onCompleted: {
                self.parentPlatformState.accept(.idle)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
}
