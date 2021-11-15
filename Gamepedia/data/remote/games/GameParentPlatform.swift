//
//  ParentPlatform.swift
//  Gamepedia
//
//  Created by Dzaky on 20/09/21.
//

import UIKit

struct GameParentPlatform: Codable {
    let platform: Platform
    enum CodingKeys: String, CodingKey {
        case platform
    }
}

struct GamePlatform: Codable {
    let id: Int
    let name: String
    let slug: String
   
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
    }
}
