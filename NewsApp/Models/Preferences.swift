//
//  Preferences.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 05.09.24.
//

import Foundation

public struct FavoriteDomain: Codable, Hashable {
    public let domain: String
    public let likedAt: Date

    public init(domain: String, likedAt: Date) {
        self.domain = domain
        self.likedAt = likedAt
    }
}

@objc(Preferences)
public class Preferences: NSObject, NSSecureCoding, Codable {
    public var domains: [FavoriteDomain]
    public var authors: [String]
    public var articleIDs: [String]
    public var eventIDs: [String]

    // NSSecureCoding requires this
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // Initializer for normal use
    init(domains: [FavoriteDomain], authors: [String], articleIDs: [String], eventIDs: [String]) {
        self.domains = domains
        self.authors = authors
        self.articleIDs = articleIDs
        self.eventIDs = eventIDs
    }

    // Implement the encode method for NSSecureCoding
    public func encode(with coder: NSCoder) {
            coder.encode(domains, forKey: "domains")
            coder.encode(authors, forKey: "authors")
            coder.encode(articleIDs, forKey: "articleIDs")
            coder.encode(eventIDs, forKey: "eventIDs")
    }

    // Implement the init method for decoding
    required public init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(forKey: "domains") as? [FavoriteDomain],
              let authors = coder.decodeObject(forKey: "authors") as? [String],
              let articles = coder.decodeObject(forKey: "articleIDs") as? [String],
              let events = coder.decodeObject(forKey: "eventIDs") as? [String] else {
            return nil
        }
        self.domains = domains
        self.authors = authors
        self.articleIDs = articles
        self.eventIDs = events
    }
}
