//
//  BaseListViewModel.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 05.11.24.
//

import Foundation
import CoreData

class BaseListViewModel<T:NSManagedObject>: ObservableObject {
    public var plistHelper: PlistHelper
    public var coreDataViewModel: CoreDataViewModel
    
    @Published var items: [T] = []
    
    init(plistHelper: PlistHelper = PlistHelper(), coreDataViewModel: CoreDataViewModel) {
        self.plistHelper = plistHelper
        self.coreDataViewModel = coreDataViewModel
    }
    
    @MainActor
    func fetchItems(lastSyncTime: String? = "2024-08-24 11:27:00") async -> [T] {
        do {
            let fetchedItems = try await fetchFromAPI(with: lastSyncTime)
            if !fetchedItems.isEmpty {
                items = sortItems(items: fetchedItems)
            } else {
                let fetchedItems = await loadFromCoreData()
                items = sortItems(items: fetchedItems)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            let fetchedItems = await loadFromCoreData()
            items = sortItems(items: fetchedItems)
        }
        
        return items
    }
    
    func fetchFromAPI(with lastSyncTime: String?) async throws -> [T] { [] }
    
    func loadFromCoreData() async -> [T] {
        var coreDataEvents: [T] = []
        do {
            coreDataEvents = try await self.coreDataViewModel.extractDataFromCoreData() as [T]
            return coreDataEvents
        }
        catch {
            print(error, error.localizedDescription)
        }
        
        return coreDataEvents
    }
    
    func sortItems(items: [T]) -> [T] { [] }
}


final class EventsListViewModel: BaseListViewModel<Event> {
    
    override func fetchFromAPI(with lastSyncTime: String?) async throws -> [Event] {
        guard let api_link: String = plistHelper.extractValueWithKey(key: "api_link") else {
            print("No value was extracted from Plist")
            return []
        }
        
        let apiService = APIService(apiURL: api_link)
        
        do {
            // Fetch data from the API
            let jsonEvents = try await apiService.fetchData(from: "events")
            
            var uploadedEvents = try await Task.detached { () -> [Event] in
                        // Process articles on a background thread
                return try await self.coreDataViewModel.uploadEvents(with: jsonEvents)
                }.value

            if !uploadedEvents.isEmpty {
                uploadedEvents = sortItems(items: uploadedEvents)
            }
            
            return uploadedEvents
        }
        catch {
            print("Error caught: \(error.localizedDescription)")
            return []
        }
    }
    
    override func sortItems(items: [Event]) -> [Event] {
        let events = items.sorted {
            if let date1 = $0.start_date, let date2 = $1.start_date {
                return date1 > date2
            }
            return false
        }
        return events
    }
}

final class ArticlesListViewModel: BaseListViewModel<Article> {
    
    override func fetchFromAPI(with lastSyncTime: String?) async throws -> [Article] {
        
        guard let api_link: String = plistHelper.extractValueWithKey(key: "api_link") else {
            print("No value was extracted from Plist")
            return []
        }
        
        let apiService = APIService(apiURL: api_link, lastSyncTime: lastSyncTime!)
        
        do {
            // Fetch data from the API
            let jsonArticles = try await apiService.fetchData(from: "articles", with: lastSyncTime)
            
            var uploadedArticles = await Task.detached { () -> [Article] in
                        // Process articles on a background thread
                return await self.coreDataViewModel.uploadArticlesToCoreData(jsonArticles: jsonArticles)
                }.value

            if !uploadedArticles.isEmpty {
                uploadedArticles = uploadedArticles.sorted { article1, article2 in
                    guard let date1 = article1.pubDate else { return false }
                    guard let date2 = article2.pubDate else { return true }
                    return date1 > date2
                }
            }
            
            return uploadedArticles
        }
        catch {
            print("Error caught: \(error.localizedDescription)")
            return []
        }
    }
    
    override func sortItems(items: [Article]) -> [Article] {
        guard let articles_count: Int = plistHelper.extractValueWithKey(key: "articles_count") else {
            print("No value was extracted from Plist")
            return []
        }
        let articles = items.sorted {
            if let date1 = $0.pubDate, let date2 = $1.pubDate {
                return date1 > date2
            }
            return false
        }
        if articles.count > articles_count {
            return Array(articles[0..<articles_count])
        }
        return articles
    }
}
