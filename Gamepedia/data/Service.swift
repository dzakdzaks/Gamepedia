//
//  Service.swift
//  Gamepedia
//
//  Created by Dzaky on 16/09/21.
//
import UIKit

let baseUrl = "https://api.rawg.io/api"
let apiKey = "41283ebf1d7f44ca87506eb97566c2ce"


func getGames(searchKey: String, ordering: String, page: String, pageSize: String, onSuccess: @escaping ((Games) -> Void), onFailure: @escaping ((String) -> Void)) {
    var gamesUrlComponent = URLComponents(string: "\(baseUrl)/games")!
    
    gamesUrlComponent.queryItems = [
        URLQueryItem(name: "page", value: page),
        URLQueryItem(name: "page_size", value: pageSize),
        URLQueryItem(name: "key", value: apiKey)
    ]
    
    if !searchKey.isEmpty {
        gamesUrlComponent.queryItems?.append(
            URLQueryItem(name: "search", value: searchKey)
        )
    }
    
    if !ordering.isEmpty {
        gamesUrlComponent.queryItems?.append(
            URLQueryItem(name: "ordering", value: ordering)
        )
    }
    
    
    let request = URLRequest(url: gamesUrlComponent.url!)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let response = response as? HTTPURLResponse else { return }
        if let data = data {
            if (200...299).contains(response.statusCode) {
                if let games = try? JSONDecoder().decode(Games.self, from: data) as Games {
                    onSuccess(games)
                } else {
                    onFailure("Failed to decode data.")
                }
            } else {
                onFailure("\(response.statusCode) : \(response.description)")
            }
        }
    }.resume()
    
}

func getDetailGame(gameId: String, onSuccess: @escaping ((Game) -> Void), onFailure: @escaping ((String) -> Void)) {
    
    var url = URLComponents(string: "\(baseUrl)/games/\(gameId)")!
    
    url.queryItems = [
        URLQueryItem(name: "key", value: apiKey)
    ]
    
    let request = URLRequest(url: url.url!)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let response = response as? HTTPURLResponse else { return }
        if let data = data {
            if (200...299).contains(response.statusCode) {
                if let game = try? JSONDecoder().decode(Game.self, from: data) as Game {
                    onSuccess(game)
                } else {
                    onFailure("Failed to decode data.")
                }
            } else {
                onFailure("\(response.statusCode) : \(response.description)")
            }
        }
    }.resume()
}

