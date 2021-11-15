//
//  Publisher.swift
//  Gamepedia
//
//  Created by Dzaky on 24/09/21.
//

import Foundation


struct Publisher: Codable {
    let id: Int
    let name: String
    let slug: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
    }
}
