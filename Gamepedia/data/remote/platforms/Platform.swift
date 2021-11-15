//
//  Platform.swift
//  Gamepedia
//
//  Created by Dzaky on 12/11/21.
//

import Foundation

struct Platform: Codable {
    
    let id: Int
    let name: String
    let slug: String
    let gamesCount: Int
    let imageBackground: String
    let image: String
    let yearStart: Int
    let yearEnd: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case gamesCount = "games_count"
        case imageBackground = "image_background"
        case image
        case yearStart = "year_start"
        case yearEnd = "year_end"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        name = (try? container.decode(String.self, forKey: .name)) ?? "-"
        slug = (try? container.decode(String.self, forKey: .slug)) ?? ""
        gamesCount = (try? container.decode(Int.self, forKey: .gamesCount)) ?? 0
        imageBackground = (try? container.decode(String.self, forKey: .imageBackground)) ?? ""
        image = (try? container.decode(String.self, forKey: .image)) ?? ""
        yearStart = (try? container.decode(Int.self, forKey: .yearStart)) ?? 0
        yearEnd = (try? container.decode(Int.self, forKey: .yearEnd)) ?? 0
    }
    
}
