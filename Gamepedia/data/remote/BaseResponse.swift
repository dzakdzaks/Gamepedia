//
//  Data.swift
//  Gamepedia
//
//  Created by Dzaky on 12/11/21.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    let count: Int
    let next: String
    let previous: String
    let results: T
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = (try? container.decode(Int.self, forKey: .count)) ?? 0
        next = (try? container.decode(String.self, forKey: .next)) ?? "-"
        previous = (try? container.decode(String.self, forKey: .previous)) ?? "-"
        results = try container.decode(T.self, forKey: .results)
    }
    
}
