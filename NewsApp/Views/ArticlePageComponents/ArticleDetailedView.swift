//
//  ArticleDetailedView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 20.08.24.
//

import SwiftUI

struct ArticleDetailedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var userPreference: UserPreference?
    
    @State private var isLoading = true
    @State private var gotoLogin: Bool = false
    
    @State private var isFavoriteArticle: Bool = false
    @State private var isFavoriteAuthor: Bool = false
    @State private var isFavoriteSite: Bool = false
    
    @State private var isShowingAuthorPopover: Bool = false
    @State private var isShowingSitePopover: Bool = false
    
    let article: Article
        
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        Task {
                            try await loadUserPreference()
                        }
                    }
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(article.title ?? "Error: No title provided")
                            .fontWeight(.bold)
                            .font(.title)
                            .onTapGesture {
                                if let url = URL(string: article.link ?? "") {
                                    openURL(url)
                                }
                            }
                        
                        ScrollView(.horizontal, showsIndicators: false)  {
                            HStack {
                                Text(article.author ?? "Error: No author provided")
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(.black)
                                    .cornerRadius(3.0)
                                    .onTapGesture {
                                        self.isShowingAuthorPopover.toggle()
                                    }
                                    .popover(isPresented: $isShowingAuthorPopover, arrowEdge: .bottom, content:  {
                                            Button {
                                                isFavoriteAuthor.toggle()
                                                Task {
                                                    if !isFavoriteAuthor {
                                                        await coreDataService.removeUserPrefernces(userPreference: userPreference ?? nil, author: article.author)
                                                    } else {
                                                        await coreDataService.saveUserPreferences(userPreference: userPreference ?? nil, author: article.author)
                                                    }
                                                }
                                            } label: {
                                                HStack(alignment: .center) {
                                                    Image(systemName: isFavoriteAuthor ? "star.fill" :"star")
                                                    Text(isFavoriteAuthor ? "Added to favourites" : "Add to favourites")
                                                }
                                                .padding()
                                            }
                                            .presentationCompactAdaptation(.popover)
                                        }
                                    )
                                
                                Text("\(convertDateToString(date: article.pubDate))")
                                    .underline(true)
                                
                                Text(article.domain ?? "Error: No domain provided")
                                    .onTapGesture {
                                        self.isShowingSitePopover.toggle()
                                    }
                                    .popover(isPresented: $isShowingSitePopover, arrowEdge: .bottom, content:  {
                                        Button {
                                            isFavoriteSite.toggle()
                                            Task {
                                                guard let domain = article.domain else { return }
                                                if !isFavoriteSite {
                                                    await coreDataService.removeUserPrefernces(userPreference: userPreference!, domain: FavoriteDomain(domain: domain, likedAt: Date()))
                                                } else {
                                                    await coreDataService.saveUserPreferences(userPreference: userPreference!, domain: FavoriteDomain(domain: domain, likedAt: Date()))
                                                }
                                            }
                                        } label: {
                                            HStack(alignment: .center) {
                                                Image(systemName: isFavoriteSite ? "star.fill" :"star")
                                                Text(isFavoriteSite ? "Added to favourites" : "Add to favourites")
                                            }
                                            .padding()
                                        }
                                        .presentationCompactAdaptation(.popover)
                                    })
                                
                            }
                            .font(.subheadline)
                            .padding(.bottom)
                        }
                    
                        Text(article.descrip ?? "Error: No description provided")
                            .padding(.vertical)
                        Text(article.maintext ?? "Error: No article text provided")
                            .font(.body)
                            .padding(.vertical)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .navigationDestination(isPresented: $gotoLogin) {
                    LoginPageView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isFavoriteArticle.toggle()
                    Task {
                        guard let userPreference else {
                            gotoLogin = true
                            return
                        }
                        if isFavoriteArticle {
                            await coreDataService.saveUserPreferences(userPreference: userPreference, article: article)
                        }
                        else {
                            await coreDataService.removeUserPrefernces(userPreference: userPreference, article: article)
                        }
                    }
                })
                {
                    withAnimation(.bouncy) {
                        Image(systemName: isFavoriteArticle ? "heart.fill" : "heart")
                            .imageScale(.large)
                            .foregroundColor(isFavoriteArticle ? .red : .black)
                    }
                }
            }
        }
    }
    
    func convertDateToString(date: Date?) -> String {
        guard let date else { return "Error: No date provided." }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func loadUserPreference() async throws  {
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
        //searching current article in users favorite
        if let articleIDs = userPreference?.preference?.articleIDs, (articleIDs.contains {$0 == article.id!.uuidString}) {
            isFavoriteArticle = true
        }
        if let authors = userPreference?.preference?.authors, (authors.contains {$0 == article.author!}) {
            isFavoriteAuthor = true
        }
        //(domains.contains {$0 == article.domain!}
        if let domains = userPreference?.preference?.domains, let articleDomain = article.domain, let domain = domains.first(where: {$0.domain == articleDomain}) {
            isFavoriteSite = true
        }
        isLoading = false
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let articleEntity = Article(context: viewContext)
    
    ArticleDetailedView(article: articleEntity)
        .environment(\.managedObjectContext, viewContext)
}
