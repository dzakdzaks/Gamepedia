//
//  Client.swift
//  Gamepedia
//
//  Created by Dzaky on 23/09/21.
//

import Foundation
import RxSwift
import RxCocoa

extension String: Error {}

final class Client {
    
    func call<T: Codable>(resource: Resource) -> Observable<[T]> {
        return data(resource: resource).map { data in
            guard let result = try? JSONDecoder().decode([T].self, from: data) as [T] else {
                throw "Failed to decode data"
            }
            
            return result as [T]
        }
    }
    
    func call<T: Codable>(resource: Resource) -> Observable<T> {
        return data(resource: resource).map { data in
            guard let result = try? JSONDecoder().decode(T.self, from: data) as T else {
                throw "Failed to decode data"
            }
            
            return result as T
        }
    }
    
    private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private func data(resource: Resource) -> Observable<Data> {
        
        return Observable.create { observer in
            
            
            let task = self.session.dataTask(with: resource.request()) { data, response, error in
                print("wakwaw \(String(describing: resource.request().url))")
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? RxCocoaURLError.unknown))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(RxCocoaURLError.nonHTTPResponse(response: response)))
                    return
                }
                
                if (httpResponse.statusCode / 100) == 2 {
                    observer.on(.next(data))
                    observer.on(.completed)
                } else {
                    observer.on(.error("\(httpResponse.statusCode) || \(httpResponse.description)"))
                }
                
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
            
        }
        
    }
    
}
