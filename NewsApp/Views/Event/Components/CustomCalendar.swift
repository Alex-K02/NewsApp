//
//  CustomCalendar.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI

struct CustomCalendar: View {
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel
    
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @Binding var selectedDate: Date
    @State private var daysCount: [Date] = []
    
    @State private var events: [Date : [Event]] = [Date : [Event]]()
    
    let opacity = 1.0
    
    var body: some View {
        VStack {
            CustomDatePickerView(selectedDate: $selectedDate)
                .padding(.bottom)
            HStack {
                //or use indicies
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.black)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(daysCount, id:\.self) { dayNumber in
                    if dayNumber.monthInt != selectedDate.monthInt{
                         Text("")
                    } else {
                        VStack(spacing: 0) { // Adjust spacing here
                            Text(dayNumber.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .overlay(alignment: .topTrailing) {
                                    let todaysEvents = events[dayNumber]
                                    if let todaysEvents, !todaysEvents.isEmpty {
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(Color(red: 0.349, green: 0.125, blue: 0.933))
                                            .offset(x: 0, y: -5)
                                    }
                                }
                            //today
                            if Calendar.current.isDate(Date.now, inSameDayAs: dayNumber) {
                                Rectangle()
                                    .frame(height: 3) // Set underline thickness
                                    .foregroundColor(.purple)
                                    .frame(maxWidth: .infinity) // Make underline full width
                            }
                            else if Calendar.current.isDate(dayNumber, inSameDayAs: selectedDate){ //chosen date
                                Rectangle()
                                    .frame(height: 3) // Set underline thickness
                                    .foregroundColor(Color(red: 0.349, green: 0.125, blue: 0.933))
                                    .frame(maxWidth: .infinity) // Make underline full width
                            }
                        }
                        .onTapGesture {
                            selectedDate = dayNumber
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 0.8)) {
                self.daysCount = selectedDate.calendarDisplayDates
            }
        }
        .onChange(of: selectedDate) {
            withAnimation(Animation.easeInOut(duration: 1.0)) {
                self.daysCount = selectedDate.calendarDisplayDates
            }
        }
        .task {
            var fetchedEvents = eventsListViewModel.events
            if fetchedEvents.isEmpty {
                fetchedEvents = await eventsListViewModel.fetchEvents()
            }
            events = Dictionary(grouping: fetchedEvents, by: { extractDay(from: $0.start_date!)})
        }
    }
    
    func extractDay(from date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

#warning("check if caching is needed")
extension Date {
    private var cachedStartDateOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    private var cachedEndDateOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: cachedStartDateOfMonth)!
        return Calendar.current.dateInterval(of: .month, for: dayInPreviousMonth)!.start
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: cachedEndDateOfMonth)
    }
    
    var sundayBeforeStart: Date {
        let startOfMonthWeekDay = Calendar.current.component(.weekday, from: cachedStartDateOfMonth)
        let numberFromPreviousMonth = startOfMonthWeekDay - 1
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: cachedStartDateOfMonth)!
    }
    
    var calendarDisplayDates: [Date] {
        var dates: [Date] = []
        let currentMonthDays = numberOfDaysInMonth
        
        // Only add dates from the current month within the range
        for day in 0..<currentMonthDays {
            if let newDay = Calendar.current.date(byAdding: .day, value: day, to: cachedStartDateOfMonth),
               newDay >= sundayBeforeStart && newDay <= cachedEndDateOfMonth {
                dates.append(newDay)
            }
        }
        
        // Only add dates from the previous month within the range
        let previousMonthDays = startOfPreviousMonth.numberOfDaysInMonth
        for day in 0..<previousMonthDays {
            if let newDay = Calendar.current.date(byAdding: .day, value: day, to: startOfPreviousMonth),
               newDay >= sundayBeforeStart && newDay <= cachedEndDateOfMonth {
                dates.append(newDay)
            }
        }
        
        return dates.sorted(by: <)
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
}

#Preview {
    @Previewable @EnvironmentObject var eventsListViewModel: EventsListViewModel
    @Previewable @State var selectedDate: Date = Date.now
    CustomCalendar(selectedDate: $selectedDate)
}
