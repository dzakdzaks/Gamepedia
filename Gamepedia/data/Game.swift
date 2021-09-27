//
//  Game.swift
//  Gamepedia
//
//  Created by Dzaky on 16/09/21.
//

import UIKit


struct Game: Codable {
    let id: Int
    let name: String
    let releaseDate: String?
    let backgroundImage: String?
    let rating: Double?
    let ratingTop: Double?
    let parentPlatforms: [ParentPlatform]?
    let genres: [Genre]?
    let esrbRating: EsrbRating?
    var descriptionRaw: String?
    var developers: [Developer]?
    var publishers: [Publisher]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case releaseDate = "released"
        case backgroundImage = "background_image"
        case rating
        case ratingTop = "rating_top"
        case parentPlatforms = "parent_platforms"
        case genres
        case esrbRating = "esrb_rating"
        case descriptionRaw = "description_raw"
        case developers
        case publishers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        releaseDate = (try? container.decode(String?.self, forKey: .releaseDate)) ?? "-"
        backgroundImage = (try? container.decode(String?.self, forKey: .backgroundImage))
        rating = (try? container.decode(Double?.self, forKey: .rating)) ?? 0.0
        ratingTop = (try? container.decode(Double?.self, forKey: .ratingTop)) ?? 0.0
        parentPlatforms = (try? container.decode([ParentPlatform].self, forKey: .parentPlatforms)) ?? nil
        genres = (try? container.decode([Genre].self, forKey: .genres)) ?? nil
        esrbRating = (try? container.decode(EsrbRating.self, forKey: .esrbRating)) ?? nil
        descriptionRaw = (try? container.decode(String?.self, forKey: .descriptionRaw)) ?? "-"
        developers = (try? container.decode([Developer].self, forKey: .developers))
        publishers = (try? container.decode([Publisher].self, forKey: .publishers))
    }
    
    func getImageURL() -> URL? {
        guard let image = backgroundImage, let url = URL(string: image) else {
            return nil
        }
        return url
    }
    
    func getReleaseDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let formattedReleaseDate = dateFormatter.date(from: releaseDate ?? "") else { return "-" }
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: formattedReleaseDate)
    }
}


struct Games: Codable {
    let games: [Game]
    
    enum CodingKeys: String, CodingKey {
        case games = "results"
    }
}
