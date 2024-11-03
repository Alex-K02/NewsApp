//
//  User+CoreDataProperties.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 24.09.24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var email: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var salt: String?
    @NSManaged public var userIdPreference: UserPreference?

}

extension User : Identifiable {

}
