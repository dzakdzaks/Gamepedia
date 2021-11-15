//
//  OrderBy.swift
//  Gamepedia
//
//  Created by Dzaky on 17/09/21.
//

import UIKit

struct OrderBy {
    let key: String
    let value: String
}

func generateOrderBy() -> [OrderBy] {
    return [
        OrderBy(key: "-relevance", value: "Relevance"),
        OrderBy(key: "-created", value: "Date added"),
        OrderBy(key: "-name", value: "Name"),
        OrderBy(key: "-released", value: "Release date"),
        OrderBy(key: "-added", value: "Popularity"),
        OrderBy(key: "-rating", value: "Average rating"),
        OrderBy(key: "", value: "Clear")
    ]
}
