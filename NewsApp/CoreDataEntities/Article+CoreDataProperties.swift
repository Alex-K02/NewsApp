//
//  Article+CoreDataProperties.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 24.09.24.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var author: String?
    @NSManaged public var descrip: String?
    @NSManaged public var domain: String?
    @NSManaged public var downDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var link: String?
    @NSManaged public var maintext: String?
    @NSManaged public var pubDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var articleSummaryId: ArticleSummary?

}

extension Article : Identifiable {

}
