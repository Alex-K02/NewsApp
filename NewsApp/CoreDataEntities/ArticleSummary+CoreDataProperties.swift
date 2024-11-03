//
//  ArticleSummary+CoreDataProperties.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 24.09.24.
//
//

import Foundation
import CoreData


extension ArticleSummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleSummary> {
        return NSFetchRequest<ArticleSummary>(entityName: "ArticleSummary")
    }

    @NSManaged public var concepts: String?
    @NSManaged public var entities: String?
    @NSManaged public var id: UUID?
    @NSManaged public var subterms: String?
    @NSManaged public var terms: String?
    @NSManaged public var titles: String?
    @NSManaged public var articleId: Article?

}

extension ArticleSummary : Identifiable {

}
