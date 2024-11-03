//
//  AuthViewModel.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 11.09.24.
//

import Foundation
import KeychainSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

enum KeyExtractionError: Error {
    case missingKey
}

class AuthViewModel: ObservableObject {
    @Published var userJWTSessionToken: String?
    
    private let keychain = KeychainSwift()
    private let jwtHelper = JWTHelper()
    private let plistHelper = PlistHelper()
    
    private let key: String?
    
    init() {
        // Handle optional value without throwing
        if let loadedKey:String? = plistHelper.extractValueWithKey(key: "jwt_key") {
            self.key = loadedKey!
        }
        else {
            self.key = nil
            print("Warning: 'jwt_key' not found in plist")
            return
        }
        // Continue with further initialization
        loadJWTFromKeychain()
    }
    
    func loadIdValue(token: String?) -> String? {
        guard token != nil else {
            print("Error: No token provided")
            return ""
        }
        let token = keychain.get(key!)!
        return jwtHelper.idDecoder(token: token, key: key!)!
    }
    
    func loadRememberMeValue(token: String?) -> Bool {
        guard token != nil else {
            return true
        }
        let token = keychain.get(key!)!
        return jwtHelper.rememberMeDecoder(token: token, key: key!)
    }
    
    //how to get a token if it is bundeled with user
    func storeJWTInKeychain(token: String) {
        keychain.set(token, forKey: key!, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        userJWTSessionToken = token
    }
    
    func loadJWTFromKeychain() {
        if let token = keychain.get(key!),
           !token.isEmpty,
           jwtHelper.verifyJWTToken(token, key: key!) {
            userJWTSessionToken = token  // Set the retrieved token
        } else {
            print("User is not logged in or token is invalid")
            userJWTSessionToken = nil  // No valid token found
        }
    }
    
    // Remove JWT from Keychain on logout
    func removeJWTFromKeychain() {
        keychain.delete(key!)
        userJWTSessionToken = nil
    }

    // Check if JWT exists and is valid
    func isUserLoggedIn() -> Bool {
        if let token = userJWTSessionToken {
            // Here you can add logic to verify the token (e.g., decode it and check expiry)
            if jwtHelper.verifyJWTToken(token, key: key!) {
                return true
            }
        }
        return false
    }

    func logOut() {
        removeJWTFromKeychain()
        userJWTSessionToken = nil  // Clear the user object
    }

    // Handle user login
    func logIn(user: User, rememberMe: Bool) {
        let token = jwtHelper.generateJWTToken(user: user, key: key!, rememberMe: rememberMe)
        storeJWTInKeychain(token: token!)
    }
}
