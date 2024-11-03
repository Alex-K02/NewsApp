//
//  NavigationCategoriesView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 15.09.24.
//

import SwiftUI

struct NavigationCategoriesView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.primary, lineWidth: 1.5))
    }
}

#Preview {
    NavigationCategoriesView(text: "Test")
}
