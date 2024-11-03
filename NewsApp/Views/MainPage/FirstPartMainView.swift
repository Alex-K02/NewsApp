//
//  FirstMainPartView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct FirstPartMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    
    let articles: [Article]
    var articleAllocations: [Int]
    
    var body: some View {
        LogoNameView()
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    NavigationCategoriesView(text: "Category 1")
                    NavigationCategoriesView(text: "Category 2")
                    NavigationCategoriesView(text: "Category 3")
                }
            }
            .padding(.bottom)
            
            Text("What's new today")
                .textCase(.uppercase)
                .fontWeight(.bold)
            
            if let mainArticle = articles.first {
               NavigationLink(destination: ArticleDetailedView(article: mainArticle)) {
                   MainNewsBlockView(article: mainArticle)
                       .padding(.bottom, 10)
               }
            }
            
            // SubArticleBlockViews for the next set of articles
            LazyVStack(alignment: .leading) {
                ForEach(articles.dropFirst(1).prefix(articleAllocations[1])) { article in
                    NavigationLink(destination: ArticleDetailedView(article: article)) {
                        SubArticleBlockView(article: article)
                    }
                }
            }
            
            let smallArticles = Array(articles.dropFirst(articleAllocations[1]).prefix(articleAllocations[2]))  // Limit to 2 articles
            let articlePairs = smallArticles.chunked(into: 2)
            
            LazyVStack {
                ForEach(articlePairs, id: \.self) { pair in
                    HStack {
                        ForEach(pair) { article in
                            NavigationLink(destination: ArticleDetailedView(article: article)) {
                                SmallArticleBlockView(article: article)
                            }
                        }
                    }
                }
            }
        }
        .foregroundStyle(.black)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
//    FirstPartMainView()
    AnyView(EmptyView())
}
