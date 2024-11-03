//
//  UserPreference+CoreDataProperties.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 24.09.24.
//
//

import Foundation
import CoreData


extension UserPreference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreference> {
        return NSFetchRequest<UserPreference>(entityName: "UserPreference")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var preference: Preferences?
    @NSManaged public var userId: User?

}

extension UserPreference : Identifiable {

}
