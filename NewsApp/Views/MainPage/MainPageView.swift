//
//  MainPage.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

enum Tab {
    case main
    case account
    case events
}

struct MainPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthTokenManagerService
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    
    @State private var articles: [Article] = []
    @State private var events: [Event] = []
    @State private var isLoading: Bool = true
    
    @State private var selection: Tab = .main

    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                MainTabContentView(articles: $articles, isLoading: $isLoading, articleListViewModel: articleListViewModel, coreDataService: coreDataService)
                .tabItem {
                    Label("Main", systemImage: "newspaper")
                }
                .tag(Tab.main)
                
                EventPageView()
                    .tabItem {
                        Label("Events", systemImage: "calendar.badge.clock")
                    }
                    .tag(Tab.events)
                
                ProfileView()
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                    .tag(Tab.account)
            }
        }
        .task {
            await loadArticles()
        }
        
    }
    
    
    // Async function to load articles
    private func loadArticles() async {
        do {
            var fetchedArticles = articleListViewModel.items
            if fetchedArticles.isEmpty {
                fetchedArticles = await articleListViewModel.fetchItems()
            }
            let evaluatedArticles = try await coreDataService.evaluateArticles(newArticles: fetchedArticles)
            let sortedArticles = try await coreDataService.sortByDateAndScore(articles: evaluatedArticles)
            
            if !sortedArticles.isEmpty {
                articles = sortedArticles.map(\.article)
            }
            else {
                articles = articleListViewModel.items
            }
            isLoading = false
        } catch {
            print("Error loading articles: \(error.localizedDescription)")
        }
    }
}

struct MainTabContentView: View {
    @Binding var articles: [Article]
    @Binding var isLoading: Bool
    @ObservedObject var articleListViewModel: ArticlesListViewModel
    let coreDataService: CoreDataService
    
    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    ProgressView("Loading articles...")
                        .padding()
                } else if articles.isEmpty {
                    Text("No articles found...")
                        .padding()
                } else {
                    let halfOfArray = Array(articles.prefix(articles.count / 2))
                    FirstPartMainView(articles: halfOfArray, articleAllocations: self.defineArticleAllocation(articles: halfOfArray))
                    BrowseAllMainView(articles: Array(articles.suffix(from: (articles.count / 2) + 1)))
                }
            }
            .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height, alignment: .center)
        }
    }
    
    func defineArticleAllocation(articles: [Article]) -> [Int] {
        var allocations: [Int] = []
        //only 1 main article
        allocations.append(1)
        
        var rest = articles.count
        
        //allocating the article 50 - 50 for the 2 rest blocks
        if (articles.count - 1) % 2 == 0 {
            rest -= (articles.count - 1) / 2
            allocations.append((articles.count - 1) / 2)
        }
        else {
            rest -= ((articles.count - 2) / 2) + 1
            allocations.append(((articles.count - 2) / 2) + 1)
        }
        
        allocations.append(rest)
        return allocations
    }
}



#Preview {
    MainPageView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
