//
//  ArticlesListViewModel.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 28.08.24.
//

import Foundation

class ArticlesListViewModel: ObservableObject {
    private var plistHelper = PlistHelper()
    private var coreDateService: CoreDataService
    
    init(coreDataService: CoreDataService) {
        self.coreDateService = coreDataService
    }
    
    @Published var isLoading = false
    @Published var articles: [Article] = []
    
    @MainActor
    func fetchArticles(lastSyncTime: String? = "2024-08-24 11:27:00") async -> [Article] {
        isLoading = true
        defer { isLoading = false } // use defer to ensure it’s toggled back

        do {
            // Try fetching articles from API first
            let fetchedArticles = try await fetchFromAPI(with: lastSyncTime)
            if !fetchedArticles.isEmpty {
                articles = sortArticles(articles: fetchedArticles)
            } else {
                // If no articles from API, load from Core Data
                let fetchedArticles: [Article] = await loadFromCoreData()
                articles = sortArticles(articles: fetchedArticles)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            // If there’s an error, load from Core Data as a fallback
            let fetchedArticles: [Article] = await loadFromCoreData()
            articles = sortArticles(articles: fetchedArticles)
        }

        return articles
    }
    
    func sortArticles(articles: [Article]) -> [Article] {
        guard let articles_count: Int = plistHelper.extractValueWithKey(key: "articles_count") else {
            print("No value was extracted from Plist")
            return []
        }
        let articles = articles.sorted {
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
    

    func fetchFromAPI(with lastSyncTime: String?="2024-08-24 11:27:00") async throws -> [Article] {
        // Fetch the API link from Plist
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
                return await self.coreDateService.uploadArticlesToCoreData(jsonArticles: jsonArticles)
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
    
    public func loadFromCoreData() async -> [Article]{
        var coreDataArticles: [Article] = []
        
        do {
            coreDataArticles = try await coreDateService.extractDataFromCoreData() as [Article]
            // date sorting
            coreDataArticles = coreDataArticles.sorted { article1, article2 in
                guard let date1 = article1.pubDate else { return false }
                guard let date2 = article2.pubDate else { return true }
                return date1 > date2
            }
            return coreDataArticles
        }
        catch {
            print(error, error.localizedDescription)
        }
        
        return coreDataArticles
    }
}
