//
//  EventsDetailedView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 28.10.24.
//

import SwiftUI

struct EventsDetailedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var coreDataService: CoreDataService
    
    let event: Event
    @State private var isEventUnique: Bool = true
    
    var body: some View {
        VStack {
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
                            IconLabel(iconName: "calendar", label: convertDateToString(startDate: event.start_date, endDate: event.end_date))
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
                        Text("Be Part of the Future of Tech – Get Your Spot at \(event.title ?? "this Event.") Before Tickets Run Out!")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.body)
                            .padding(.horizontal)
                            .padding(.top)
                        Button("Join \(event.title ?? "Event")") {
                            if let url = URL(string: event.registration_link ?? event.link ?? "") {
                                openURL(url)
                            }
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
                
                SaveEventButtonView(
                    title: isEventUnique ? "Save this event to your calendar" : "Saved to the calendar",
                    imageName: isEventUnique ? "bookmark" : "bookmark.fill",
                    action: {
                        if isEventUnique {
                            CalendarService.shared.saveEvent(with: event)
                            isEventUnique.toggle()
                        }
                        else {
                            CalendarService.shared.openEventInCalendar(with: event)
                        }
                })
                
                EventsBackButtonView(action: {
                    dismiss()
                })
            }
            .navigationBarBackButtonHidden(true)
        }
        .task {
            isEventUnique = CalendarService.shared.isEventUnique(event)
        }
    }
    
    func convertDateToString(startDate: Date?, endDate: Date?) -> String {
        guard let startDate, let endDate else { return "Error: No date provided." }
        //fomatters
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        //
        let strStartDate = dayFormatter.string(from: startDate)
        let strEndDate = dayFormatter.string(from: endDate)
        
        let year = yearFormatter.string(from: startDate)
        
        
        if startDate.monthInt == endDate.monthInt {
            let month = monthFormatter.string(from: startDate)
            return "\(month) \(strStartDate) - \(strEndDate), \(year) "
        }
        else {
            let startMonth = monthFormatter.string(from: startDate)
            let endMonth = monthFormatter.string(from: endDate)
            return "\(startMonth) \(strStartDate) - \(endMonth) \(strEndDate), \(year) "
        }
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
                        if !person.isEmpty {
                            Text("• \(person)")
                                .padding(.leading, 10)
                        }
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
                .multilineTextAlignment(.center)
                .font(.callout)
        }
    }
}

struct SaveEventButtonView: View {
    var title: String
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack {
                HStack(spacing: 5) {
                    Text(title)
                    Image(systemName: imageName)
                }
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.black, lineWidth: 3)
            }
            .padding(.top)
            .padding(.horizontal)
        })
    }
}

#Preview {
    @Previewable @Environment(\.managedObjectContext) var viewContext
    let eventEntity = Event(context: viewContext)
    
    EventsDetailedView(event: eventEntity)
        .environment(\.managedObjectContext, viewContext)
    //ListBlockView(iconName: "person", label: "speakers", data: [])
}
