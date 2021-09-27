//
//  MainViewModek.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation
import RxSwift
import RxRelay

enum MainState {
    case idle, loading, complete, error(msg: String)
}

enum DetailState {
    case idle, loading, complete(game: Game), error(msg: String)
}

class MainViewModel {
    
    let client: Client = Client()
    let disposeBag: DisposeBag = DisposeBag()
    
    var gamesSearches: [Game] = []
        
    var searchKey: String = ""
    var ordering: String = ""
    var page: Int = 1
    
    var selectedGameRow: Int? = nil
    
    var isLoadMore: Bool = false
    
    let pageSize = "10"
    
    let state = BehaviorRelay<MainState>(value: .idle)
    
    let detailstate = BehaviorRelay<DetailState>(value: .idle)
    
    init() {
        getGames()
    }

    func getGames() {
        
        state.accept(.loading)
        
        client.getGames(searchKey: searchKey, ordering: ordering, page: String(page), pageSize: pageSize)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { games in
                if self.isLoadMore {
                    self.gamesSearches.insert(contentsOf: games.games, at: self.gamesSearches.count)
                } else {
                    self.gamesSearches.insert(contentsOf: games.games, at: 0)
                }
            }, onError: { error in
                self.state.accept(.error(msg: error.localizedDescription))
            }, onCompleted: {
                self.state.accept(.complete)
            }, onDisposed: {
                
            }
            ).disposed(by: disposeBag)
        
    }
}
