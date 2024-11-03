//
//  CustomPickerCategoryView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 01.10.24.
//

import SwiftUI

struct CustomPickerCategoryView: View {
    var categoryTitle: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(categoryTitle)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(isSelected ? Color(red: 98/255, green: 92/255, blue: 246/255).opacity(0.9) : Color.clear)
                .cornerRadius(10)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Bool = true
    CustomPickerCategoryView(categoryTitle: "Titles", isSelected: selectedTab, action: {
        print("Some action")
    })
}
