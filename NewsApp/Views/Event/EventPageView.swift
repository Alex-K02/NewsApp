//
//  EventPageView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct EventPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var events: [Date : [Event]] = [:]
    @State private var isLoading: Bool = true
    @State private var selectedDate: Date = Date()
    
    @State private var userId: String?
    @State private var userPreference: UserPreference?
    
    @State private var isEventMarkedFavorite: Bool = false
    @State private var userFavoriteEvents: [String] = []
    
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading articles...")
                    .padding()

            }
            else if events.isEmpty {
                Text("No events found...")
                    .padding()
            }
            else {
                VStack(alignment: .leading) {
                    EventTitleBlockView(title: "Events")
                    
                    CustomCalendar(selectedDate: $selectedDate)
                    
                    VStack {
                        HStack {
                            Image(systemName: "list.bullet")
                                .imageScale(.large)
                            NavigationLink(destination: AllEventsPageView()) {
                                Text("View all")
                                    .font(.title2)
                                    .underline()
                                    .fontWeight(.bold)
                                    .accentColor(.black)
                            }
                        }
                            
                        
                        ScrollView {
                            LazyVStack {
                                if let currentDateEvents = events[extractDay(from: selectedDate)] {
                                    ForEach(currentDateEvents, id: \.self) { event in
                                        EventBlockView(event: event)
                                    }
                                } else {
                                    Text("There are no events on this day :(")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .task {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        Task {
            await loadUserPreference()
            
            if eventsListViewModel.items.isEmpty {
                let fetchedEvents = await eventsListViewModel.fetchItems()
                events = Dictionary(grouping: fetchedEvents, by: { extractDay(from: $0.start_date!) })
            } else {
                events = Dictionary(grouping: eventsListViewModel.items, by: { extractDay(from: $0.start_date!) })
            }
            isLoading = false
        }
    }
    
    func extractDay(from date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    func loadUserPreference() async {
        // Load JWT from Keychain
        authViewModel.loadJWTFromKeychain()
        
        // Check if user is logged in
        guard authViewModel.isUserLoggedIn(),
              let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return
        }
        
        self.userId = loadedUserId
        
        // Fetch data from Core Data
        Task {
            let userPreferences = try await coreDataService.extractDataFromCoreData() as [UserPreference]
            // Find user by ID
            if let foundUserPreference = userPreferences.first(where: { $0.id?.uuidString == userId }){
                self.userPreference = foundUserPreference
                
                self.userFavoriteEvents = foundUserPreference.preference?.eventIDs ?? []
            } else {
                print("User not found in Core Data.")
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    
    EventPageView()
        .environment(\.managedObjectContext, viewContext)
}
