//
//  SmallFavoriteBlockView.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 02.10.24.
//

import SwiftUI

struct ProfileDomainBlockView: View {
    @Binding var showPopUp: Bool
    let addingDate: Date
    let domain: String?
    var onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // White background with rounded corners and border
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.white))//red: 0.455, green: 0.498, blue: 1
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
            
            HStack(alignment: .center) {
                // Title at the top left
                VStack(alignment: .leading, spacing: 2) {
                    // Author name with truncation
                    Text(domain ?? "")
                        .lineLimit(1) // Limit to 1 line and truncate if necessary
                        .truncationMode(.tail)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    // Added date with truncation
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .imageScale(.small)
                        Text("Added \(addingDate) days ago")
                            .lineLimit(1) // Limit to 1 line and truncate if necessary
                            .truncationMode(.tail)
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                    }
                }
                .padding(.vertical, 10)
                .foregroundColor(.black) // Ensuring text color

                Spacer()

                // Source text at the bottom right
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPopUp.toggle()
                        }
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .imageScale(.medium)
                            .cornerRadius(3.0)
                    }
                }
                .foregroundStyle(.red)
                .padding(.vertical)
            }
            .padding(.horizontal, 10) // Padding for the content inside the background
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)
        .padding(.bottom, 14)
    }
}

#Preview {
    @Previewable @State var showPopUp: Bool = true
    @Previewable @State var domain: String? = "example.com"
    let date = Date()
    ProfileDomainBlockView(showPopUp: $showPopUp, addingDate: date, domain: domain, onDelete: { print("removing from the favorites")})
}
