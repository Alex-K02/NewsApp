//
//  ArticleHorizontalView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct ArticleHorizontalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State var userPreference: UserPreference?
    
    @State private var isShowingAuthorPopover: Bool = false
    @State private var isShowingSitePopover: Bool = false
    
    @State private var isFavoriteAuthor: Bool = false
    @State private var isFavoriteSite: Bool = false
    
    let article: Article
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false)  {
            HStack {
                Text(article.author!)
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
                                    await coreDataService.removeUserPrefernces(userPreference: userPreference ?? nil, article: nil, domain: "", author: article.author)
                                } else {
                                    await coreDataService.saveUserPreferences(userPreference: userPreference ?? nil, article: nil, domain: "", author: article.author)
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
                
                Text("\(convertDateToString(date: article.pubDate!))")
                    .underline(true)
                
                Text(article.domain!)
                    .onTapGesture {
                        self.isShowingSitePopover.toggle()
                    }
                    .popover(isPresented: $isShowingSitePopover, arrowEdge: .bottom, content:  {
                        Button {
                            isFavoriteSite.toggle()
                            Task {
                                if !isFavoriteSite {
                                    await coreDataService.removeUserPrefernces(userPreference: userPreference!, article: nil, domain: article.domain!, author: "")
                                } else {
                                    await coreDataService.saveUserPreferences(userPreference: userPreference!, article: nil, domain: article.domain!, author: "")
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
    }
}

func convertDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
    let formattedDate = dateFormatter.string(from: date)
    return formattedDate
}

#Preview {
    let viewContext = PersistenceController.shared.container.viewContext
    // Create the article entity inside the context
    let articleEntity = Article(context: viewContext)
    articleEntity.title = "Test Title"
    articleEntity.author = "Author"
    articleEntity.pubDate = Date()
    articleEntity.link = "somelink.com"
    articleEntity.maintext = "Some test main text"
    articleEntity.descrip = "Some description"
    articleEntity.domain = "link.com"
    articleEntity.downDate = Date()
    return ArticleHorizontalView(article: articleEntity)
        .environment(\.managedObjectContext, viewContext)
}
