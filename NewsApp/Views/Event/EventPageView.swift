//
//  EventPageView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct EventPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataViewModel: CoreDataViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var events: [Date : [Event]] = [:]
    @State private var isLoading: Bool = true
    @State private var selectedDate: Date = Date()
    
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
                            NavigationLink(destination:
                                            AllEventsPageView()
                                .environmentObject(eventsListViewModel)
                            ) {
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
            //checking userPreference
            if let userPreference = authViewModel.userPreference {
                self.userPreference = userPreference
            } else {
                try await authViewModel.loadUserData()
                if let loadedUserPreference = authViewModel.userPreference {
                    self.userPreference = loadedUserPreference
                } else {
                    // Handle the case where user data couldn't be loaded
                    print("Failed to load user data.")
                }
            }
            
            if let events = self.userPreference?.preference?.eventIDs {
                self.userFavoriteEvents = events
            }
            
            //fetching from Core Data
            var fetchedEvents = eventsListViewModel.items
            if fetchedEvents.isEmpty {
                fetchedEvents = await eventsListViewModel.fetchItems()
            }
            events = Dictionary(grouping: fetchedEvents, by: { extractDay(from: $0.start_date!) })
            isLoading = false
        }
    }
    
    func extractDay(from date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    
    EventPageView()
        .environment(\.managedObjectContext, viewContext)
}
