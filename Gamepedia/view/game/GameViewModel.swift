//
//  MainViewModek.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation
import RxSwift
import RxRelay

class GameViewModel {
    
    private let client: Client = Client()
    let disposeBag: DisposeBag = DisposeBag()
    
    var gamesSearches: [Game] = []
        
    var searchKey: String = ""
    var ordering: String = ""
    var page: Int = 1
    var platformId: String = ""
    var platformName: String = ""
    
    var selectedGameRow: Int? = nil
    
    var isLoadMore: Bool = false
    
    let pageSize = "10"
    
    let state = BehaviorRelay<LoadState>(value: .idle)
    
    let detailstate = BehaviorRelay<ResultState<Game>>(value: .idle)
    
    init(platformId: String = "", platformName: String = "") {
        self.platformId = platformId
        self.platformName = platformName
        getGames()
    }

    func getGames() {
        
        state.accept(.loading)
        
        client.getGames(searchKey: searchKey, ordering: ordering, page: String(page), pageSize: pageSize, platforms: platformId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                if self.isLoadMore {
                    self.gamesSearches.insert(contentsOf: data.results, at: self.gamesSearches.count)
                } else {
                    self.gamesSearches.insert(contentsOf: data.results, at: 0)
                }
            }, onError: { error in
                self.state.accept(.error(msg: error.localizedDescription))
            }, onCompleted: {
                self.state.accept(.complete)
                self.state.accept(.idle)
            }, onDisposed: {
                
            }
            ).disposed(by: disposeBag)
        
    }
    
    func getGameDetail(gameId: String) {
        detailstate.accept(.loading)
        client.getGameDetail(gameId: gameId)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { game in
                    self.detailstate.accept(.complete(data: game))
                }, onError: { error in
                    self.detailstate.accept(.error(msg: error.localizedDescription))
                }, onCompleted: {
                    self.detailstate.accept(.idle)
                }, onDisposed: nil
            ).disposed(by: disposeBag)
    }
}
