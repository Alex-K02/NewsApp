//
//  MainNewsBlockView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct MainNewsBlockView: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image block
            Image("sign-in-background")
                .resizable()
                .cornerRadius(8)
            
            // Text block overlaid on the image
            ZStack(alignment: .bottomTrailing) {
                // White background with rounded corners and border
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                
                VStack(alignment: .leading) {
                    // Title at the top left
                    Text(article.title ?? "No title provided")
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding(.top, 8)

                    Spacer()

                    // Source text at the bottom right
                    HStack {
                        Spacer() // Pushes the source text to the right
                        Text(article.domain ?? "No domain provided")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 10) // Padding for the content inside the background
            }
            .frame(height: 50) // Adjust height for the text block
        }
        .frame(height: UIScreen.main.bounds.height * 0.25) // Adjust this to match the desired image size
    }
}

#Preview {
//    MainNewsBlockView()
    AnyView(EmptyView())
}
