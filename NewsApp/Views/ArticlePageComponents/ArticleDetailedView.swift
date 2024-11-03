//
//  ArticleDetailedView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 20.08.24.
//

import SwiftUI

struct ArticleDetailedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var userId: String?
    @State private var userPreference: UserPreference?
    
    @State private var isLoading = true
    
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
                            await loadUserPreference()
                        }
                    }
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(article.title ?? "Error: No title provided")
                            .fontWeight(.bold)
                            .font(.title)
                        
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
                                                if !isFavoriteSite {
                                                    await coreDataService.removeUserPrefernces(userPreference: userPreference!, domain: article.domain!)
                                                } else {
                                                    await coreDataService.saveUserPreferences(userPreference: userPreference!, domain: article.domain!)
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isFavoriteArticle.toggle()
                    Task {
                        if isFavoriteArticle {
                            await coreDataService.saveUserPreferences(userPreference: userPreference!, article: article)
                        }
                        else {
                            await coreDataService.removeUserPrefernces(userPreference: userPreference!, article: article)
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
    
    func loadUserPreference() async {
        // Load JWT from Keychain
        authViewModel.loadJWTFromKeychain()
        
        // Check if user is logged in
        guard authViewModel.isUserLoggedIn(),
              let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken) else {
            print("No user id loaded or user not logged in.")
            return
        }
        
        self.userId = loadedUserId
        
        // Fetch data from Core Data
        Task {
            let userPreferences = try await coreDataService.extractDataFromCoreData() as [UserPreference]
            // Find user by ID
            if let foundUserPreference = userPreferences.first(where: { $0.id?.uuidString == userId }){
                self.userPreference = foundUserPreference
                
                let articleIds = foundUserPreference.preference?.articleIDs
                if ((articleIds!.contains {$0 == article.id!.uuidString}))  {
                    isFavoriteArticle = true
                }
                let authors = foundUserPreference.preference?.authors
                if ((authors!.contains {$0 == article.author!}))  {
                    isFavoriteAuthor = true
                }
                let domains = foundUserPreference.preference?.domains
                if ((domains!.contains {$0 == article.domain!}))  {
                    isFavoriteSite = true
                }
                
            } else {
                print("User not found in Core Data.")
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let articleEntity = Article(context: viewContext)
    
    ArticleDetailedView(article: articleEntity)
        .environment(\.managedObjectContext, viewContext)
}
