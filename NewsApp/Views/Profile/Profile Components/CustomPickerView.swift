//
//  CustomPickerView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 01.10.24.
//

import SwiftUI

struct CustomPickerView: View {
    private let categories = ["Articles", "Sites", "Authors", "Events"]
    @Binding var selectedTab: String
        
        var body: some View {
            VStack {
                HStack(spacing: 0) {
                    ForEach(categories, id:\.self) {category in
                        CustomPickerCategoryView(
                            categoryTitle: category,
                            isSelected: selectedTab == category,
                            action: {
                                selectedTab = category
                            }
                        )
                        .padding(.horizontal, 2)
                    }
                }
                .padding(.vertical, 2)
                .font(.footnote)
                .background(Color(.systemGray6)) // Background of the container
                .cornerRadius(10) // Rounded corners to match the style
                .padding(.horizontal, 15) // Adjust the padding to match the width
                .padding(.vertical, 5)
            }
            .padding()
        }
}

#Preview {
    @Previewable @State var selectedTab: String = "Authors"
    CustomPickerView(selectedTab: $selectedTab)
}
