//
//  isFavoriteView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 25.09.24.
//

import SwiftUI

struct isFavoriteView: View {
    @Binding var isFavorite: Bool
    
    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Button(action: {isFavorite.toggle()}) {
                    Image(systemName: isFavorite ? "heart.fill" :"heart")
                        .imageScale(.large)
                }
                .foregroundStyle(isFavorite ? .red : .black)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var isFavorite: Bool = false
    isFavoriteView(isFavorite: $isFavorite)
}
