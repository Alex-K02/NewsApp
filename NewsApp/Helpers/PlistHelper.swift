//
//  PlistHelper.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 15.09.24.
//

import Foundation

struct PlistHelper {
    private let plistFileName = "EnvVars"
    private let plistFileType = "plist"
    
    func extractValueWithKey<T>(key: String) -> T? {
        guard let path = Bundle.main.path(forResource: plistFileName, ofType: plistFileType),
             let plistData = NSDictionary(contentsOfFile: path) else {
           print("Failed to load plist data.")
           return nil
       }

       // Safely cast the fetched data to the expected type T
       if let fetchedData = plistData[key] as? T {
           return fetchedData
       } else {
           print("Failed to cast data for key \(key) to type \(T.self).")
           return nil
       }
    }
}
