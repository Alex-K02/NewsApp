//
//  UserDataViewModel.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 06.10.24.
//

import Foundation
#warning("Check how to implement this module in project")
class UserDataViewModel {
    
    // Properties to store user data
    var userId: String?
    var user: User?
    var email: String = ""
    var dateOfBirth: Date = Date()
    
    // Dependencies
    private var authViewModel: AuthViewModel
    private var coreDataService: CoreDataService
    
    // Constructor to inject dependencies
    init(authViewModel: AuthViewModel, coreDataService: CoreDataService) {
        self.authViewModel = authViewModel
        self.coreDataService = coreDataService
    }
    
    // Main function to load user data
    func loadUserData() async throws {
        // Load JWT from Keychain
        authViewModel.loadJWTFromKeychain()
        
        // Check if user is logged in and retrieve the user ID
        guard authViewModel.isUserLoggedIn(),
              let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken) else {
            throw UserDataError.userNotLoggedIn
        }
        
        self.userId = loadedUserId // Store the user ID
        
        // Fetch the user directly from Core Data by userId
        if let foundUser = try await coreDataService.fetchUserById(userId: userId!) {
            self.user = foundUser
            self.email = foundUser.email ?? "No email"
            self.dateOfBirth = foundUser.dateOfBirth ?? Date()
        } else {
            throw UserDataError.userNotFound
        }
    }
    
    enum UserDataError: Error {
        case userNotLoggedIn
        case userNotFound
    }
}
