//
//  APIService.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 28.08.24.
//

import Foundation

struct APIService {
    var apiURL: String
    var lastSyncTime: String?
    
    func fetchData(
        from table: String,
        with latestSyncTime: String? = nil,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) async throws -> Data {
        var data: Data = .init()
        var response: URLResponse?
        
        var urlComponents = URLComponents(string: self.apiURL)!
        
        // checking when was the latestSyncTime
        if let latestSyncTime {
            urlComponents.queryItems = [
                URLQueryItem(name: "last_working_time", value: latestSyncTime),
                URLQueryItem(name: "from", value: table)
            ]
        }
        else {
            urlComponents.queryItems = [
                URLQueryItem(name: "from", value: table)
            ]
        }
        
        guard let urlWithQuery = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        do {
            (data, response) = try await URLSession.shared.data(from: urlWithQuery)
            guard let httpsResponse = response as? HTTPURLResponse, httpsResponse.statusCode == 200 else {
                throw APIError.invalidResponseStatus
            }
        }
        catch {
            // Handle network or other errors
            throw APIError.dataTaskError(error.localizedDescription)
        }
        
        // Initialize JSONDecoder with custom strategies
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        // Decode the data
        do {
            let jsonStringData = try decoder.decode(String.self, from: data)
            
            // Convert the JSON string into `Data`
            guard let jsonData = jsonStringData.data(using: .utf8) else {
                throw APIError.decodingError("Failed to convert string to Data")
            }
            return jsonData // Successfully decoded, return the result
        }
        catch {
            print("Unknown decoding error: \(error.localizedDescription)")
            throw APIError.decodingError("Unknown decoding error: \(error.localizedDescription)")
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid!", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("The API is failed to issue a valid response!", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("The data provided is happen to be corrupt!", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}
