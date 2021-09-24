//
//  Resource.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation

let baseUrl = "https://api.rawg.io/api"
let apiKey = "41283ebf1d7f44ca87506eb97566c2ce"


enum Method: String {
    case GET, POST, PUT, DELETE
}

protocol Resource {
    var method: Method { get }
    var path: String { get }
    var parameters: [String: String] { get }
}

extension Resource {
    
    func request() -> URLRequest {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.rawg.io"
        components.path = "/api/\(path)"
        components.queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        components.queryItems?.append(URLQueryItem(name: "key", value: apiKey))
        
        guard let finalUrl = components.url else {
            fatalError("Failed to get URL.")
        }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue
        
        // Send post-request with string
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    
        return request
    }
}
