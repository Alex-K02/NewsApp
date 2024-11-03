//
//  Article.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 19.08.24.
//

import Foundation

public class NewsArticle: NSObject, Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let link: String
    public let domain: String
    public let descrip: String?
    public let maintext: String
    public let pubDate: String?
    public let downDate: String?
    public let author: String
    public let titles: String
    public let concepts: String
    public let entities: String
    public let terms: String
    public let subterms: String
    
    init(id: UUID, title: String, link: String, domain: String, descrip: String, maintext: String, pubDate: String?, downDate: String?, author: String, titles: String, concepts: String, entities: String, terms: String, subterms: String) {
        self.id = id
        self.title = title
        self.link = link
        self.domain = domain
        self.descrip = descrip // Updated to reflect renaming
        self.maintext = maintext
        self.pubDate = pubDate
        self.downDate = downDate
        self.author = author
        self.titles = titles
        self.concepts = concepts
        self.entities = entities // Fixed duplicate assignment
        self.terms = terms
        self.subterms = subterms
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title
        case link
        case domain
        case descrip = "description"
        case maintext = "main_content"
        case pubDate = "pub_date"
        case downDate = "down_date"
        case author
        case titles
        case concepts
        case entities
        case terms
        case subterms = "sub_terms"
    }
}
