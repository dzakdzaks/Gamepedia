//
//  ParentPlatform.swift
//  Gamepedia
//
//  Created by Dzaky on 12/11/21.
//

import Foundation

struct ParentPlatform: Codable {
    
    let id: Int
    let name: String
    let slug: String
    let platforms: [Platform]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        name = (try? container.decode(String.self, forKey: .name)) ?? "-"
        slug = (try? container.decode(String.self, forKey: .slug)) ?? ""
        platforms = (try? container.decode([Platform].self, forKey: .platforms)) ?? []
    }
    
}

