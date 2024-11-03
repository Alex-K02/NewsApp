//
//  EventsDetailedView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 28.10.24.
//

import SwiftUI

struct EventsDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var coreDataService: CoreDataService
    
    let event: Event
    
    var body: some View {
        Text(event.title ?? "Error: No title")
            .font(.largeTitle)
            .fontWeight(.bold)
        
        ScrollView {
            VStack {
                Grid {
                    GridRow {
                        IconLabel(iconName: "mappin.and.ellipse", label: event.location ?? "Location is not available yet")
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1) // Vertical divider
                        //FIXME: - create a date formatter
                        IconLabel(iconName: "calendar", label: "November 28, 2025")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Divider()
                        .frame(height: 1.2)
                        .background(Color.white) // Horizontal divider
                        .padding(.horizontal)
                    
                    GridRow {
                        IconLabel(iconName: "person.2.fill", label: event.event_type ?? "Event type is not available yet")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1) // Vertical divider
                        
                        IconLabel(iconName: "dollarsign", label: event.price ?? "Price is not available yet")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    }
                }
                .padding()
                .background(EventGradientBackground())
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .padding(.bottom)
                
                HStack {
                    Image(systemName: "i.circle")
                    Text(event.summary ?? "Error: No summary available")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                }
                .padding(.horizontal, 10)
                .padding(.bottom)
                
                HStack(spacing: 100) {
                    ListBlockView(iconName: "person", label: "Speakers", data: event.speakers ?? "")
                    ListBlockView(iconName: "dollarsign", label: "Sponsors", data: event.sponsors ?? "")
                }
                .padding(.bottom)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Be Part of the Future of Tech – Get Your Spot at \(event.title ?? "") Before Tickets Run Out!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.body)
                        .padding(.horizontal)
                        .padding(.top)
                    Button("Join WWDC 2025") {
                        print("sending user to the website")
                    }
                    .frame(maxWidth: .infinity)
                    .accentColor(.white)
                    .padding()
                    .background(Color(red: 0.349, green: 0.125, blue: 0.933))// #5920ee
                    .cornerRadius(20)
                    .padding()
                }
                .background(
                    EventGradientBackground()
                )
                .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            
            EventsBackButtonView(action: {
                dismiss()
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}


// MARK: - Reusable Views and Modifiers
struct ListBlockView: View {
    let iconName: String
    let label: String
    let data: String
    
    @State private var transformedData: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconName)
                Text(label)
                    .multilineTextAlignment(.center)
            }
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.bottom, 5)
            
            if transformedData.isEmpty {
                Text("No information about \(label) provided")
            }
            else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(transformedData, id: \.self) { person in
                        Text("• \(person)")
                            .padding(.leading, 10)
                    }
                }
            }
        }
        .task {
            self.transformedData = transformData(data)
        }
    }
    
    func transformData(_ data: String) -> [String] {
        let transformedData: [String]? = data.components(separatedBy: ",")
        guard let transformedData else {
            return []
        }
        return transformedData
    }
}

struct IconLabel: View {
    var iconName: String
    var label: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.bottom, 2)
            Text(label)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true) // Allows multiline text
                .font(.system(size: 14))
        }
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    
    EventsDetailedView(event: eventEntity)
        .environment(\.managedObjectContext, viewContext)
    //ListBlockView(iconName: "person", label: "speakers", data: [])
}
