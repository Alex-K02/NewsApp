//
//  SmallFavoriteBlockView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 02.10.24.
//

import SwiftUI

struct ProfileDomainBlockView: View {
    @Binding var showPopUp: Bool
    let domain: FavoriteDomain?
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
                    Text(domain?.domain ?? "")
                        .lineLimit(1) // Limit to 1 line and truncate if necessary
                        .truncationMode(.tail)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    // Added date with truncation
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .imageScale(.small)
                        Text("Added \(countHowManyDaysAgo(from: domain?.likedAt ?? Date()))")
                            .lineLimit(1) // Adjust to 1 line for concise display
                            .truncationMode(.tail)
                            .font(.subheadline)
                            .fontWeight(.light)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
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
    
    private func countHowManyDaysAgo(from date: Date) -> String {
        let daysFromDate = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        switch daysFromDate {
        case 0:
            return "today"
        case 1:
            return "yesterday"
        default:
            return "\(daysFromDate) days ago"
        }
    }
}

#Preview {
    @Previewable @State var showPopUp: Bool = true
    @Previewable @State var domain: FavoriteDomain? = FavoriteDomain(domain: "", likedAt: Date())
    ProfileDomainBlockView(showPopUp: $showPopUp, domain: domain, onDelete: { print("removing from the favorites")})
}
