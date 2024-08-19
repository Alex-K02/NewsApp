//
//  combiningSqlAndSwiftApp.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 19.08.24.
//

import SwiftUI

@main
struct combiningSqlAndSwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
