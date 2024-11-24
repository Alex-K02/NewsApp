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
    @StateObject private var coreDataService: CoreDataService
    @StateObject private var eventsListViewModel: EventsListViewModel
    @StateObject private var articlesListViewModel: ArticlesListViewModel
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        let coreDataService = CoreDataService(viewContext: persistenceController.container.viewContext)
        _coreDataService = StateObject(wrappedValue: coreDataService)
        _eventsListViewModel = StateObject(wrappedValue: EventsListViewModel(coreDataService: coreDataService))
        _articlesListViewModel = StateObject(wrappedValue: ArticlesListViewModel(coreDataService: coreDataService))
        _authViewModel = StateObject(wrappedValue: AuthViewModel(coreDataService: coreDataService))
        NotificationManager.shared.requestPermission { success in
            if success {
                print("Permission granted!")
            } else {
                print("Permission denied.")
            }
        }
        CalendarService.shared.requestPermission()
    }
    
            
    var body: some Scene {
        WindowGroup {
            if authViewModel.isUserLoggedIn() {
                MainPageView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(coreDataService)
                    .environmentObject(authViewModel)
                    .environmentObject(eventsListViewModel)
                    .environmentObject(articlesListViewModel)
                    .onAppear() {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
            }
            else {
                LoginPageView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(coreDataService)
                    .environmentObject(authViewModel)
                    .environmentObject(eventsListViewModel)
                    .environmentObject(articlesListViewModel)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive {
                Task {
                    await coreDataService.disablePeriodicDataSync()
                }
                // Remove session from Keychain when app goes to inactive
                authViewModel.isRememberMeEnabled()
            }
            else if scenePhase == .active {
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
