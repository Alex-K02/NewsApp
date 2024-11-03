//
//  MainPage.swift
//  combiningSqlAndSwift
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
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    
    @State private var articles: [Article] = []
    @State private var events: [Event] = []
    @State private var isLoading: Bool = true
    
    @State private var selection: Tab = .main

    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ScrollView {
                    VStack {
                        if articleListViewModel.isLoading {
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
                .task {
                    do {
                        articles = articleListViewModel.articles
                        if articles.isEmpty {
                            articles = await articleListViewModel.fetchArticles()
                        }
                        // Evaluate articles (assuming this scores the articles)
                        let articleScores = try await coreDataService.evaluateArticles(newArticles: articles)
                        // Sort by date and score, returning the sorted articles
                        let sortedArticleScores = try await coreDataService.sortByDateAndScore(articles: articleScores)
                        // Extract only the articles from the sorted list
                        if !sortedArticleScores.isEmpty {
                            self.articles = sortedArticleScores.map(\.article)
                        }
                        
                        self.isLoading = false
                    } catch {
                        // Handle any errors that occur in the chain
                        print("Error loading and processing articles: \(error)")
                        print("Error loading events: \(error.localizedDescription)")
                    }
                }
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
