//
//  SmallArticleBlockView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct SmallArticleBlockView: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // White background with rounded corners and border
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.851, green: 0.851, blue: 0.851))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
            
            VStack(alignment: .leading) {
                // Title at the top left
                Text(article.title ?? "Title")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                Text(article.descrip ?? "Description")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.top, 4)

                Spacer()

                // Source text at the bottom right
                HStack {
                    Spacer() // Pushes the source text to the right
                    Text("Source: \(article.domain ?? "Domain")")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 10) // Padding for the content inside the background
        }
        .frame(width: UIScreen.main.bounds.width * 0.45, height: 140) // Adjust height for the text block
    }
}

#Preview {
    let viewContext = PersistenceController.shared.container.viewContext
    // Create the article entity inside the context
    let articleEntity = Article(context: viewContext)
    articleEntity.title = String("Test Title")
    articleEntity.author = "Author"
    articleEntity.pubDate = Date()
    articleEntity.link = "somelink.com"
    articleEntity.maintext = "Some test main text"
    articleEntity.descrip = "Some description"
    articleEntity.domain = "link.com"
    articleEntity.downDate = Date()
        return SmallArticleBlockView(article: articleEntity)
            .environment(\.managedObjectContext, viewContext)
}
