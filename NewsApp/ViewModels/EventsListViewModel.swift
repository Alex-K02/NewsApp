//
//  EventListViewModel.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 22.10.24.
//

import Foundation

class EventsListViewModel: ObservableObject {
    private let plistHelper: PlistHelper = PlistHelper()
    private var coreDateService: CoreDataService
    
    init(coreDataService: CoreDataService) {
        self.coreDateService = coreDataService
    }
    
    @Published var isLoading = false
    @Published var events: [Event] = []
    
    @MainActor
    func fetchEvents(lastSyncTime: String?="2024-08-24 11:27:00") async -> [Event] {
        isLoading = true
        defer { isLoading = false } // use defer to ensure it’s toggled back

        do {
            // Try fetching articles from API first
            let fetchedEvents = try await fetchFromAPI(with: lastSyncTime)
            if !fetchedEvents.isEmpty {
                events = sortEvents(events: fetchedEvents)
            } else {
                // If no articles from API, load from Core Data
                let fetchedEvents: [Event] = await loadFromCoreData()
                events = sortEvents(events: fetchedEvents)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            // If there’s an error, load from Core Data as a fallback
            let fetchedEvents: [Event] = await loadFromCoreData()
            events = sortEvents(events: fetchedEvents)
        }

        return events
        
    }
    
    #warning("check if not too dangerous (can crash)")
    func extractDay(from date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    private func sortEvents(events: [Event]) -> [Event] {
        let events = events.sorted {
            if let date1 = $0.start_date, let date2 = $1.start_date {
                return date1 > date2
            }
            return false
        }
        return events
    }
    
    func fetchFromAPI(with lastSyncTime: String?="2024-08-24 11:27:00") async throws -> [Event] {
        // Fetch the API link from Plist
        guard let api_link: String = plistHelper.extractValueWithKey(key: "api_link") else {
            print("No value was extracted from Plist")
            return []
        }
        
        let apiService = APIService(apiURL: api_link, lastSyncTime: lastSyncTime!)
        
        do {
            // Fetch data from the API
            let jsonEvents = try await apiService.fetchData(from: "events")
            
            var uploadedEvents = try await Task.detached { () -> [Event] in
                        // Process articles on a background thread
                return try await self.coreDateService.uploadEvents(with: jsonEvents)
                }.value

            if !uploadedEvents.isEmpty {
                uploadedEvents = sortEvents(events: uploadedEvents)
            }
            
            return uploadedEvents
        }
        catch {
            print("Error caught: \(error.localizedDescription)")
            return []
        }
    }
    
    
    public func loadFromCoreData() async -> [Event]{
        var coreDataEvents: [Event] = []
        
        do {
            coreDataEvents = try await coreDateService.extractDataFromCoreData() as [Event]
            // date sorting
            coreDataEvents = coreDataEvents.sorted { article1, article2 in
                guard let date1 = article1.start_date else { return false }
                guard let date2 = article2.start_date else { return true }
                return date1 > date2
            }
            return coreDataEvents
        }
        catch {
            print(error, error.localizedDescription)
        }
        
        return coreDataEvents
    }
}
