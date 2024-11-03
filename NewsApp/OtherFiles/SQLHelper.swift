//
//  SQLHelper.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 26.09.24.
//

import Foundation

class SQLConverter {
    let sqlHandler = SQLHandler()
    private var errorMessage: String? = nil
    
    public func fetchArticles() async -> [NewsArticle]? {
        do {
            let fetchedArticles = try await sqlHandler.extractArticles()
            
            // Assuming fetchedArticles is [MySQLRow], convert it to [Article]
            let convertedArticles = fetchedArticles.map { row -> NewsArticle in
                // Convert each row to an Article object
                return NewsArticle(
                    id: row.column("article_id")!.uuid!,
                    title: row.column("title")?.string ?? "",
                    link: row.column("link")?.string ?? "",
                    domain: row.column("domain")?.string ?? "",
                    descrip: row.column("description")?.string ?? "",
                    maintext: row.column("main_content")?.string ?? "",
                    pubDate: row.column("pub_date")?.string ?? "",
                    downDate: row.column("down_date")?.string ?? "",
                    author: row.column("link")?.string ?? "",
                    titles: row.column("titles")?.string ?? "",
                    concepts: row.column("concepts")?.string ?? "",
                    entities: row.column("entities")?.string ?? "",
                    terms: row.column("terms")?.string ?? "",
                    subterms: row.column("sub_terms")?.string ?? ""
                )
            }
            //print(convertedArticles)
            return convertedArticles
            
        } catch {
            errorMessage = error.localizedDescription // Update the state with the error message
            print("Error: \(errorMessage ?? "Unknown error")")
            return nil
        }
    }
    
    public func fetchArtilceSummary() async throws -> [NewsArticleSummary] {
        do {
            let fetchedArticlesSummaries = try await sqlHandler.extractArticles()
            
            // Assuming fetchedArticles is [MySQLRow], convert it to [Article]
            let convertedArticleSummaries = fetchedArticlesSummaries.map { row -> NewsArticleSummary in
                // Convert each row to an Article object
                return NewsArticleSummary(
                    id: row.column("article_id")!.uuid!,
                    titles: row.column("titles")?.string ?? "",
                    concepts: row.column("concepts")?.string ?? "",
                    entities: row.column("entities")?.string ?? "",
                    terms: row.column("terms")?.string ?? "",
                    subterms: row.column("sub_terms")?.string ?? ""
                )
            }
            //print(convertedArticles)
            return convertedArticleSummaries
            
        } catch {
            errorMessage = error.localizedDescription // Update the state with the error message
            print("Error: \(errorMessage ?? "Unknown error")")
            return []
        }
    }
}
