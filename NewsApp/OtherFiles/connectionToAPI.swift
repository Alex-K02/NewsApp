//
//  connectionToAPI.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 24.08.24.
//

import Foundation


func fetchArticlesFromApi(completion: @escaping ([NewsArticle]?) -> Void) {
    var urlComponents = URLComponents(string: "http://127.0.0.1:5000/db/articles")!

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    if let parsedDate = dateFormatter.date(from: "2024-08-24 11:27:00") {
        let formattedDate = dateFormatter.string(from: parsedDate)

        urlComponents.queryItems = [
            URLQueryItem(name: "last_working_time", value: formattedDate)
        ]

        if let urlWithQuery = urlComponents.url {
            let task = URLSession.shared.dataTask(with: urlWithQuery) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                do {
                    let jsonString = try JSONDecoder().decode(String.self, from: data)
                    
                    // Step 2: Convert the decoded JSON string back to Data
                    if let jsonData = jsonString.data(using: .utf8) {
                        
                        // Step 3: Decode the JSON data into the `Article` struct
                        let article = try JSONDecoder().decode([NewsArticle].self, from: jsonData)
                        completion(article)
                            
                    } else {
                        print("Error: Unable to convert JSON string to Data")
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            }
            task.resume()
        } else {
            print("Error creating the URL with query parameters.")
        }
    } else {
        print("Error parsing the date string.")
    }
}
