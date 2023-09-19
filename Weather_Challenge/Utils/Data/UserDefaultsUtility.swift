//
//  UserDefaultsUtility.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/19/23.
//

import Foundation

class UserDefaultsUtility {

    // The method for saving generic object to UserDefaults
    static func saveObjectToUserDefaults<T: Codable>(object: T, key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error serializing object: \(error.localizedDescription)")
        }
    }
    
    // The method for getting generic object from UserDefaults
    static func getObjectFromUserDefaults<T: Codable>(key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                return object
            } catch {
                print("Error deserializing object: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
