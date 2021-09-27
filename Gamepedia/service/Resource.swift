//
//  Resource.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation

private var apiKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "API-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'API-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'API-Info.plist'.")
    }
    // 3
    if (value.starts(with: "_")) {
      fatalError("Register for a RAWG account and get an API key at https://rawg.io/apidocs")
    }
    return value
  }
}
    
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
