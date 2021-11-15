//
//  HomeMenu.swift
//  Gamepedia
//
//  Created by Dzaky on 15/11/21.
//

import Foundation

struct HomeMenu {
    let id: Int
    let title: String
}

func generateHomeMenu() -> [HomeMenu] {
    var listMenu: [HomeMenu] = []
    listMenu.append(HomeMenu(id: 1, title: "Games"))
    listMenu.append(HomeMenu(id: 2, title: "Genres"))
    listMenu.append(HomeMenu(id: 3, title: "Creators"))
    listMenu.append(HomeMenu(id: 4, title: "Developers"))
    listMenu.append(HomeMenu(id: 5, title: "Publishers"))
    listMenu.append(HomeMenu(id: 6, title: "Stores"))
    return listMenu
}
