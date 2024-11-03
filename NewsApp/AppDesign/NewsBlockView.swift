//
//  NewsBlockView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 20.08.24.
//

import SwiftUI

struct NewsBlockView: View {
    var headline: String
    var imageName: String?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = imageName {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
            }
            Text(headline)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding(8)
        }
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    NewsBlockView(headline: "Headline", imageName: "")
}
