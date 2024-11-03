//
//  Event+CoreDataProperties.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 22.10.24.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var start_date: Date?
    @NSManaged public var end_date: Date?
    @NSManaged public var location: String?
    @NSManaged public var event_type: String?
    @NSManaged public var topics: String?
    @NSManaged public var speakers: String?
    @NSManaged public var link: String?
    @NSManaged public var registration_link: String?
    @NSManaged public var summary: String?
    @NSManaged public var price: String?
    @NSManaged public var sponsors: String?

}

extension Event : Identifiable {

}
