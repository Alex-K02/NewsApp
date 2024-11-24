//
//  AuthViewModel.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 22.11.24.
//

import Foundation
import CoreData

class AuthViewModel: ObservableObject {
    private let authTokenManager: AuthTokenManagerService = AuthTokenManagerService()
    let coreDataService: CoreDataService
    
    @Published var user: User? = nil
    @Published var userPreference: UserPreference? = nil
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        Task {
            try await loadUserData()
        }
    }
    
    func isRememberMeEnabled() {
        if !authTokenManager.loadRememberMeValue(token: authTokenManager.userJWTSessionToken) {
            authTokenManager.removeJWTFromKeychain()
        }
    }
    
    func isUserLoggedIn() -> Bool {
        // Load JWT from Keychain
        authTokenManager.loadJWTFromKeychain()
        // Check if user is logged in
        guard authTokenManager.isUserLoggedIn(),
              let loadedUserId = authTokenManager.loadIdValue(token: authTokenManager.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return false
        }
        return true
    }
    
    func loadUserData() async throws {
        guard let userID = await loadUserID(), !userID.isEmpty else {
            return
        }
        //
        do {
            try await loadUser(with: userID)
            try await loadUserPreference(with: userID)
        }
        catch {
            throw AuthError.dataLoadingFailed
        }
    }
    
    func loadUserID() async -> String?{
        // Load JWT from Keychain
        authTokenManager.loadJWTFromKeychain()
        // Check if user is logged in
        guard authTokenManager.isUserLoggedIn(),
              let loadedUserId = authTokenManager.loadIdValue(token: authTokenManager.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return nil
        }
        return loadedUserId
    }
    
    @MainActor
    func loadUser(with userID: String) async throws {
        do {
            if let foundUser = try await coreDataService.fetchUser(with: userID) {
                self.user = foundUser
            }
            else {
                throw AuthError.userNotFound
            }
        }
        catch {
            throw AuthError.dataExtractionFailed
        }
    }
    
    @MainActor
    func loadUserPreference(with userID: String) async throws {
        do {
            let userPreferences: [UserPreference] = try await coreDataService.extractDataFromCoreData()
            if let currentUserPreference = userPreferences.first(where: { $0.id?.uuidString == userID }) {
                self.userPreference = currentUserPreference
            }
            else {
                throw AuthError.userNotFound
            }
        }
        catch {
            throw AuthError.dataExtractionFailed
        }
    }
}

//MARK: - Errors

enum AuthError: Error {
    case userNotFound
    case dataExtractionFailed
    case dataLoadingFailed
}
