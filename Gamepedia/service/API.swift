//
//  API.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation
import RxSwift

enum API {
    case games(searchKey: String, ordering: String, page: String, pageSize: String)
    case gameDetail(gameId: String)
    case getParentPlatforms
}

extension API: Resource {
    
    var method: Method {
        switch self {
        case .games:
            return .GET
        case .gameDetail:
            return .GET
        case .getParentPlatforms:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .games:
            return "games"
        case let .gameDetail(gameId):
            return "games/\(gameId)"
        case .getParentPlatforms:
            return "platforms/lists/parents"
        }
    }
    
    var parameters: [String : String] {
        switch self {
        case let .games(searchKey, ordering, page, pageSize):
            
            var dictionary: [String: String] = [:]
            
            dictionary["page"] = page
            dictionary["page_size"] = pageSize
         
            if !searchKey.isEmpty {
                dictionary["search"] = searchKey
            }
            
            if !ordering.isEmpty {
                dictionary["ordering"] = ordering
            }
            
            return dictionary
        case .gameDetail:
            return [:]
        case .getParentPlatforms:
            return [:]
        }
    }
}


extension Client {
    
    class func client() -> Client {
        return Client()
    }
    
    func getGames(searchKey: String, ordering: String, page: String, pageSize: String) -> Observable<GamesResponse> {
        return call(resource: API.games(searchKey: searchKey, ordering: ordering, page: page, pageSize: pageSize))
    }
    
    func getGameDetail(gameId: String) -> Observable<Game> {
        return call(resource: API.gameDetail(gameId: gameId))
    }
    
    func getParentPlatforms() -> Observable<PlatformsResponse> {
        return call(resource: API.getParentPlatforms)
    }
    
}
