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
    @StateObject private var coreDataViewModel: CoreDataViewModel
    @StateObject private var eventsListViewModel: EventsListViewModel
    @StateObject private var articlesListViewModel: ArticlesListViewModel
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        let coreDataViewModel = CoreDataViewModel(viewContext: persistenceController.container.viewContext)
        _coreDataViewModel = StateObject(wrappedValue: coreDataViewModel)
        _eventsListViewModel = StateObject(wrappedValue: EventsListViewModel(coreDataViewModel: coreDataViewModel))
        _articlesListViewModel = StateObject(wrappedValue: ArticlesListViewModel(coreDataViewModel: coreDataViewModel))
        _authViewModel = StateObject(wrappedValue: AuthViewModel(coreDataViewModel: coreDataViewModel))
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
            MainPageView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(coreDataViewModel)
                .environmentObject(authViewModel)
                .environmentObject(eventsListViewModel)
                .environmentObject(articlesListViewModel)
                .onAppear() {
                    UNUserNotificationCenter.current().setBadgeCount(0)
                }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive {
                Task {
                    await coreDataViewModel.disablePeriodicDataSync()
                }
                // Remove session from Keychain when app goes to inactive
                authViewModel.isRememberMeEnabled()
            }
            else if scenePhase == .active {
                Task {
                    do {
                        try await coreDataViewModel.enablePeriodicDataSync(articleListViewModel: ArticlesListViewModel(coreDataViewModel: coreDataViewModel))
                    } catch {
                        print("Error enabling periodic sync: \(error)")
                    }
                }
            }
        }
    }
}
