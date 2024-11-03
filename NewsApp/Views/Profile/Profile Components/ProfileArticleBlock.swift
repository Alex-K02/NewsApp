//
//  SubArticleBlockView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 02.10.24.
//

import SwiftUI

struct ProfileArticleBlockView: View {
    @Binding var showPopUp: Bool
    let article: Article
    var onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // White background with rounded corners and border
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.white))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
            
            HStack {
                VStack(alignment: .leading) {
                    // Title at the top left
                    Text(article.title ?? "Title")
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 12)
                    
                    Text(article.descrip ?? "Description")
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.top, 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                Button(action: {
                    showPopUp.toggle()
                    onDelete()
                }) {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "trash")
                            .accentColor(.black)
                        Text("Delete")
                            .font(.headline)
                            .accentColor(.black)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.4)) // Red background with opacity
                    .cornerRadius(8)
                }
            }
        }
        .frame(height: 140) // Adjust height for the text block
    }
}

#Preview {
    @Previewable @State var showPopUp: Bool = true
    let article = Article(context: PersistenceController.shared.container.viewContext)
    ProfileArticleBlockView(showPopUp: $showPopUp, article: article, onDelete: {print("removing article from favorites")})
}
