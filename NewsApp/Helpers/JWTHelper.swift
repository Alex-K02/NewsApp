//
//  JWTService.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 11.09.24.
//

import Foundation
import JWTKit

struct Payload: JWTPayload {
    var sub: SubjectClaim  // Standard claim for subject, usually user id
    var email: String
    var rememberMe: Bool
    var exp: ExpirationClaim // Standard expiration claim
    
    // This function is used to verify that the token is still valid (e.g. has not expired)
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}


struct JWTHelper {
    private let plistHelper = PlistHelper()
    
    func idDecoder(token: String, key: String) -> String? {
        let secretKey = key
        let signer = JWTSigner.hs256(key: secretKey.data(using: .utf8)!)
        do {
            let payload = try signer.verify(token, as: Payload.self)
            return payload.sub.value
        }
        catch {
            print("Failed to decode or verify the JWT: \(error)")
        }
        
        return ""
    }
    
    func rememberMeDecoder(token: String, key: String) -> Bool  {
        let secretKey = key  // Secret key to sign JWT
        let signer = JWTSigner.hs256(key: secretKey.data(using: .utf8)!)
        do {
            let payload = try signer.verify(token, as: Payload.self)
            return payload.rememberMe
        } catch {
            print("Failed to decode or verify the JWT: \(error)")
        }
        return false
    }
    
    func generateJWTToken(user: User, key: String, rememberMe: Bool) -> String? {
        let secretKey = key  // Secret key to sign JWT
        let signer = JWTSigner.hs256(key: secretKey.data(using: .utf8)!) // Using HS256 signing algorithm
        
        guard let expirationTime: Double = plistHelper.extractValueWithKey(key: "expiration_time") else {
            print("No value was extracted from Plist")
            return ""
        }
        
        // Define the payload
        let payload = Payload(
            sub: SubjectClaim(value: user.id!.uuidString), // Unique user ID
            email: user.email!,
            rememberMe: rememberMe,
            exp: ExpirationClaim(value: Date().advanced(by: expirationTime)) // Expire in 1 hour
        )
        
        // Generate the JWT token
        do {
            let jwt = try signer.sign(payload)
            return jwt
        } catch {
            print("Error generating JWT: \(error)")
            return nil
        }
    }
    
    func verifyJWTToken(_ token: String, key: String) -> Bool{
        let secretKey = key
        let signer = JWTSigner.hs256(key: secretKey.data(using: .utf8)!)
        
        do {
            // Decode and verify the token
            _ = try signer.verify(token, as: Payload.self)
            return true
        } catch {
            print("Error verifying JWT: \(error)")
            return false
        }
    }
}
