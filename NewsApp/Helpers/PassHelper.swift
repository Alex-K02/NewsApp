//
//  AuthHelper.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 08.09.24.
//

import Foundation
import CryptoKit

struct PassHelper {

    public func generateSalt(length: Int = 16) -> String {
        let charset: Array<Character> = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = ""
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<length {
            result.append(charset.randomElement(using: &rng)!)
        }
        return result
    }

    // Function to hash the password with salt
    public func hashPassword(password: String, salt: String) -> String {
        let saltedPassword = salt + password
        let passwordData = Data(saltedPassword.utf8)
        let hashed = SHA256.hash(data: passwordData)
        
        return salt + ":" + hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    // Function to verify the password
    public func verifyPassword(_ password: String, hashedPasswordWithSalt: String) -> Bool {
        let components = hashedPasswordWithSalt.split(separator: ":")
        guard components.count == 2 else { return false }
        
        let salt = String(components[0])
        let storedHash = String(components[1])
        
        let hashedInputPassword = hashPassword(password: password, salt: salt)
        let hashedInputHash = hashedInputPassword.split(separator: ":")[1]
        
        return storedHash == hashedInputHash
    }
}
