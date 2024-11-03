//
//  AllEventsPageView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct AllEventsPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate: Date = .init()
    @State private var isLoading: Bool = true
    
    //@State private var events: [Event] = []
    @State private var events: [Int: [Event]] = [:]
    @State private var isEventMarkedFavorite: Bool = false
    @State private var userFavoriteEvents: [String] = []
    
    @State private var userId: String?
    @State private var userPreference: UserPreference?
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .padding()
                }
                else if events.isEmpty {
                    Text("No events found")
                }
                else {
                    eventsContent
                }
            }
            .navigationBarBackButtonHidden()
            .task { await loadEventsAndPreferences() }
        }
    }
    
    // Main event content view
    @ViewBuilder
    private var eventsContent: some View {
        ZStack {
            VStack {
                EventTitleBlockView(title: "All Events Of The Year")
                VStack {
                    CustomDatePickerView(selectedDate: $selectedDate, isShowingYearPicker: true)
                        .padding(.vertical)
                    
                    ScrollView {
                        let filteredEvents = events[extractYear(from: selectedDate)]
                        if let filteredEvents, !filteredEvents.isEmpty {
                            LazyVStack {
                                ForEach(filteredEvents, id: \.self) { event in
                                    EventBlockView(event: event)
                                }
                            }
                        } else {
                            Text("No events found for this year")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .padding(.bottom)
                .padding(.horizontal, 10)
            }
            // Bottom Button
            VStack {
                Spacer()
                EventsBackButtonView(action: {
                    dismiss()
                })
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    func extractYear(from date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }
    
    // Load events and user preferences asynchronously
    private func loadEventsAndPreferences() async {
        do {
            let fetchedEvents = await fetchEventsIfNeeded()
            events = Dictionary(grouping: fetchedEvents, by: { extractYear(from: $0.start_date!) })
            await loadUserPreference()
            isLoading = false
        } catch {
            print("Error loading events or user preferences: \(error)")
            isLoading = false
        }
    }
    
    // Fetch events if they haven't already been loaded
    private func fetchEventsIfNeeded() async -> [Event] {
        var fetchedEvents = eventsListViewModel.events
        if fetchedEvents.isEmpty {
            fetchedEvents = await eventsListViewModel.fetchEvents()
        }
        return fetchedEvents
    }
    
    // Load user preferences from CoreData
    private func loadUserPreference() async {
        authViewModel.loadJWTFromKeychain()
        guard authViewModel.isUserLoggedIn(),
              let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return
        }
        
        userId = loadedUserId
        
        do {
            let userPreferences = try await coreDataService.extractDataFromCoreData() as [UserPreference]
            if let foundUserPreference = userPreferences.first(where: { $0.id?.uuidString == userId }) {
                userPreference = foundUserPreference
                userFavoriteEvents = foundUserPreference.preference?.eventIDs ?? []
            } else {
                print("User not found in Core Data.")
            }
        } catch {
            print("Error loading user preferences: \(error)")
        }
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    
    AllEventsPageView()
        .environment(\.managedObjectContext, viewContext)
}
