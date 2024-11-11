//
//  CalendarService.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 10.11.24.
//

import Foundation
import EventKit
import UIKit

struct CalendarService {
    static let shared = CalendarService()
    private let eventStore: EKEventStore
    
    
    private init() {
        eventStore = EKEventStore()
    }
    
    func requestPermission() {
        eventStore.requestFullAccessToEvents { success, error in
            if success {
                print("Calendar permission granted")
            } else if let error {
                print("Calendar permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func isEventUnique(_ currentEvent: Event) -> Bool {
        let eventStore = EKEventStore()
        guard let startDate = currentEvent.start_date, let endDate = currentEvent.end_date else { return false }
        
        // Normalize the dates to ignore hours and minutes
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
        
        // Create a predicate covering the entire day range
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
                
        // Loop through matching events and check for title match
        for event in events {
            // Compare event titles to check for uniqueness
            if event.title == currentEvent.title {
                return false
            }
        }
        return true
    }
    
    func openEventInCalendar(with event: Event) {
        guard let startDate = event.start_date else { return }
        
        let interval = startDate.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Unable to open Calendar app.")
            }
        }
        else {
            print("Error. Invalid URL, unable to open Calendar app.")
        }
    }
    
    func saveEvent(with event: Event) {
        let eventStore = EKEventStore()
        let newEvent = EKEvent(eventStore: eventStore)
        
        guard let startDate = event.start_date, let endDate = event.end_date else { return }

        newEvent.title = event.title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.notes = event.summary
        
        newEvent.isAllDay = false
        newEvent.timeZone = TimeZone(identifier: "UTC")
        
        if let calendar = eventStore.defaultCalendarForNewEvents {
            newEvent.calendar = calendar
        } else {
            print("No default calendar available.")
            return
        }
        
        let alarmDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: -1, to: startDate)!)
        if let alarmDate = alarmDate {
            let alarm = EKAlarm(absoluteDate: alarmDate)
            newEvent.addAlarm(alarm)
        } else {
            print("Failed to create alarm date.")
        }
        
        do {
            try eventStore.save(newEvent, span: .thisEvent)
            print("Event saved successfully")
        } catch {
            print("Event was not saved!", error.localizedDescription)
        }
    }
}
