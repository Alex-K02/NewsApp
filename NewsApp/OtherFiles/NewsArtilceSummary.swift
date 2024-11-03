//
//  NewsArtilceSummary.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 26.09.24.
//

import Foundation

public class NewsArticleSummary: NSObject, Codable, Identifiable {
    public let id: UUID
    public let titles: String
    public let concepts: String
    public let entities: String
    public let terms: String
    public let subterms: String
    
    init(id: UUID, titles: String, concepts: String, entities: String, terms: String, subterms: String) {
        self.id = id
        self.titles = titles
        self.concepts = concepts
        self.entities = entities
        self.terms = terms
        self.subterms = subterms
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case titles
        case concepts
        case entities
        case terms
        case subterms = "sub_terms"
    }
}
