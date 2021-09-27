//
//  LocalGame.swift
//  Gamepedia
//
//  Created by Dzaky on 27/09/21.
//

import UIKit

struct LocalGameModel {
    var id: Int32?
    var gameId: Int32?
    var name: String?
    var releaseDate: String?
    var backgroundImage: String?
    var rating: Double?
    var ratingTop: Double?
    var parentPlatforms: String?
    var genres: String?
    var esrbRating: String?
    var descriptionRaw: String?
    var developers: String?
    var publishers: String?
    
    func getImageURL() -> URL? {
        guard let image = backgroundImage, let url = URL(string: image) else {
            return nil
        }
        return url
    }
}
