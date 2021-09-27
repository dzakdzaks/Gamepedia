//
//  ProfileModel.swift
//  Gamepedia
//
//  Created by Dzaky on 27/09/21.
//

import Foundation


struct ProfileModel {
    static let nameKey = "name"
    
    static var name: String {
           get {
               return UserDefaults.standard.string(forKey: nameKey) ?? "Muhammad Dzaky Rahmanto"
           }
           set {
               UserDefaults.standard.set(newValue, forKey: nameKey)
           }
       }
    
    static func synchronize() {
           UserDefaults.standard.synchronize()
       }

}
