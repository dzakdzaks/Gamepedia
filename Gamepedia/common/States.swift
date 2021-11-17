//
//  LoadState.swift
//  Gamepedia
//
//  Created by Dzaky on 12/11/21.
//

import Foundation

enum LoadState {
    case idle, loading, complete, error(msg: String)
}

enum ResultState<T: Any> {
    case idle, loading, complete(data: T), error(msg: String)
}

enum BannerState {
    case idle, defaultInit(selected: Int), dragged
}
