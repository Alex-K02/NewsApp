//
//  BrowseAllArticleBlockView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct BrowseAllArticleBlockView: View {
    var article: Article
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // White background with rounded corners and border
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.114, green: 0.137, blue: 0.165))
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
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10) // Padding for the content inside the background
        }
        .frame(height: 140) // Adjust height for the text block
    }
}

#Preview {
//    BrowseAllArticleBlockView()
    AnyView(EmptyView())
}
