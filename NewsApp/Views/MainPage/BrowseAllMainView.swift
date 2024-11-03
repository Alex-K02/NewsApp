//
//  BrowseAllMainView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct BrowseAllMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    
    var articles: [Article]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Browse All")
                .font(.title)
                .padding(.top, 10)
            
            LazyVStack {
                ForEach(articles.indices, id: \.self) { index in
                    let article = articles[index]
                    NavigationLink(destination: ArticleDetailedView(article: article)){
                        if article.title != nil {
                            BrowseAllArticleBlockView(article: article)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .padding(.bottom, 10)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.455, green: 0.498, blue: 1))
        .cornerRadius(8.0)  // Optional: adjust radius or remove it
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    //BrowseAllMainView()
    AnyView(EmptyView())
}
