//
//  ProfileEventBlockView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 02.11.24.
//

import SwiftUI

struct ProfileEventBlockView: View {
    @Binding var showPopUp: Bool
    let event: Event
    @State private var isMarked: Bool = true
    var onDelete: () -> Void
    
    var body: some View {
        ZStack {
            NavigationLink(destination: EventsDetailedView(event: event)) {
                HStack(alignment: .top) {
                    Image(systemName: "calendar")
                        .imageScale(.large)
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .foregroundStyle(Color(red: 0.349, green: 0.125, blue: 0.933))// #5920ee
                                .frame(width: 40, height: 40)
                        )
                        .padding(.top, 5)
                        .padding(.trailing)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(event.title ?? "Error: No title provided")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(convertDateToString(date: event.start_date ?? nil))")
                                .fontWeight(.bold)
                            
                            Text(event.summary ?? "Error: No summary provided. Error: No summary provided.")
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    }
                    .foregroundColor(.black)
                    
                    Button(action: {
                        Task {
                            withAnimation(.easeInOut) {
                                self.isMarked.toggle()
                            }
                            showPopUp.toggle()
                            onDelete()
                        }
                    }) {
                        // Toggle between checkmark and plus icons
                        Image(systemName: isMarked ? "checkmark" : "plus")
                            .imageScale(.large)
                            .cornerRadius(3.0)
                    }
                    .foregroundColor(Color(red: 0.349, green: 0.125, blue: 0.933))
                }
                .padding()
                .background(Color(red: 0.91, green: 0.898, blue: 0.992))// #e8e5fd
                .cornerRadius(20)
            }
        }
    }
    
    func convertDateToString(date: Date?) -> String {
        guard let date else {
            return "Error: No time provided"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}

#Preview {
    @Previewable @State var showPopUp: Bool = false
    @Previewable @State var isMarked: Bool = true
    let event = Event(context: PersistenceController.shared.container.viewContext)
    ProfileEventBlockView(showPopUp: $showPopUp, event: event, onDelete: {print("removing event from favorites")})
}
