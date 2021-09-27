//
//  FavoriteViewModel.swift
//  Gamepedia
//
//  Created by Dzaky on 27/09/21.
//

import Foundation
import RxSwift
import RxRelay

class FavoriteViewModel {
    
    private lazy var gameProvider: GameProvider = { return GameProvider() }()
    
    let disposeBag = DisposeBag()
    
    var games: [LocalGameModel] = []
    
    var selectedGameRow: Int? = nil
    
    let successFetchData = BehaviorRelay<Bool>(value: false)

    
    init() {
        getFavoriteGames()
    }
    
    func getFavoriteGames() {
        gameProvider.getAllGames { games in
            DispatchQueue.main.async {
                self.games = games
                self.successFetchData.accept(true)
            }
        }
    }
    
}
