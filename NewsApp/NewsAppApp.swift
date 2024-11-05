//
//  NewsApp.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 19.08.24.
//

import SwiftUI

@main
struct NewsAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let persistenceController = PersistenceController.shared
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var coreDataService: CoreDataService
    
    init() {
        let coreDataService = CoreDataService(viewContext: persistenceController.container.viewContext)
        _coreDataService = StateObject(wrappedValue: coreDataService)
        NotificationManager.shared.requestPermission { success in
            if success {
                print("Permission granted!")
            } else {
                print("Permission denied.")
            }
        }
    }
    
            
    var body: some Scene {
        WindowGroup {
            if authViewModel.isUserLoggedIn() {
                MainPageView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(coreDataService)
                    .environmentObject(authViewModel)
                    .environmentObject(EventsListViewModel(coreDataService: coreDataService))
                    .environmentObject(ArticlesListViewModel(coreDataService: coreDataService))
                    .onAppear() {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
            }
            else {
                LoginView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(coreDataService)
                    .environmentObject(authViewModel)
                    .environmentObject(EventsListViewModel(coreDataService: coreDataService))
                    .environmentObject(ArticlesListViewModel(coreDataService: coreDataService))
            }
        }
        
        .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            if newScenePhase == .inactive {
                Task {
                    await coreDataService.disablePeriodicDataSync()
                }
                if !authViewModel.loadRememberMeValue(token: authViewModel.userJWTSessionToken) {
                    // Remove session from Keychain when app goes to inactive
                    authViewModel.removeJWTFromKeychain()
                }
            }
            else if newScenePhase == .active {
                Task {
                    do {
                        try await coreDataService.enablePeriodicDataSync(articleListViewModel: ArticlesListViewModel(coreDataService: coreDataService))
                    } catch {
                        print("Error enabling periodic sync: \(error)")
                    }
                }
            }
        }
    }
}
