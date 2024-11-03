//
//  EventBlockView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct EventBlockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var userId: String?
    @State private var userPreference: UserPreference?
    
    let event: Event
    @State private var isMarked: Bool = false
    @State private var isLoading: Bool = true
    
    
    var body: some View {
        NavigationLink(destination: EventsDetailedView(event: event)) {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        Task {
                            try await loadUserPreference()
                        }
                    }
            } else {
                HStack(alignment: .top) {
                    Image(systemName: "calendar")
                        .imageScale(.large)
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .foregroundStyle(Color(red: 0.349, green: 0.125, blue: 0.933))// #5920ee
                                .frame(width: 40, height: 40)
                        )
                        .padding(.top, 5)
                        .padding(.trailing)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(event.title ?? "Error: No title provided")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(convertDateToString(date: event.start_date ?? nil))")
                                .fontWeight(.bold)
                            
                            Text(event.summary ?? "Error: No summary provided. Error: No summary provided.")
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    }
                    .foregroundColor(.black)
                    
                    Button(action: {
                        Task {
                            if let userPreference {
                                if isMarked {
                                    await coreDataService.removeUserPrefernces(userPreference: userPreference, event: event)
                                } else {
                                    await coreDataService.saveUserPreferences(userPreference: userPreference, event: event)
                                }
                            }
                            else {
                                print("No userPreference given")
                            }
                            withAnimation(.easeInOut) {
                                self.isMarked.toggle()
                            }
                        }
                    }) {
                        // Toggle between checkmark and plus icons
                        Image(systemName: isMarked ? "checkmark" : "plus")
                            .imageScale(.large)
                            .cornerRadius(3.0)
                    }
                    .foregroundColor(Color(red: 0.349, green: 0.125, blue: 0.933))
                }
                .padding()
                .background(Color(red: 0.91, green: 0.898, blue: 0.992))// #e8e5fd
                .cornerRadius(20)
            }
        }
    }
    
    func convertDateToString(date: Date?) -> String {
        guard let date else {
            return "Error: No time provided"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func loadUserPreference() async throws {
        // Load JWT from Keychain
        authViewModel.loadJWTFromKeychain()
        
        // Check if user is logged in
        guard authViewModel.isUserLoggedIn(),
              let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return
        }
        
        self.userId = loadedUserId
        
        let userPreferences = try await coreDataService.extractDataFromCoreData() as [UserPreference]
        // Find user by ID
        if let foundUserPreference = userPreferences.first(where: { $0.id?.uuidString == userId }){
            self.userPreference = foundUserPreference
            
            let eventIds = foundUserPreference.preference?.eventIDs
            if ((eventIds!.contains {$0 == event.id!.uuidString}))  {
                isMarked = true
            }
            
        } else {
            print("User not found in Core Data.")
        }
        self.isLoading = false
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    let userPreference = UserPreference(context: viewContext)
    
    EventBlockView(event: eventEntity)
        .environment(\.managedObjectContext, viewContext)
}
