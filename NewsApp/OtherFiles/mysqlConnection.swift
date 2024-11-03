//
//  mysqlConnection.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 19.08.24.
//
import Foundation
import MySQLKit
import NIOCore
import NIOPosix
import Logging

class SQLHandler {
    var logger = Logger(label: "")
    public func extractArticles() async throws -> [MySQLRow] {
        //fetching the articles from the db(mysql)
        logger.logLevel = .trace
        let mysqlConfiguration = MySQLConfiguration(
            hostname: "localhost",
            port: 3306,
            username: "root",
            password: "password",
            database: "newsapp",
            tlsConfiguration: .forClient(certificateVerification: .none)
        )
        let mysqlConnection = MySQLConnectionSource(configuration: mysqlConfiguration)
        let logger = Logger(label: "com.newsapp.mysql")
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        // Establish connection
        let connection = try await mysqlConnection.makeConnection(logger: logger, on: eventLoopGroup.next()).get()
        print("Connected to MySQL database")
        
        // Use defer to ensure the connection is closed at the end of the function
        defer {
            do {
                try connection.close().wait()  // Synchronously wait for the connection to close
                print("Connection closed successfully!")
            } catch {
                print("Failed to close connection: \(error)")
            }
        }
        
        // Execute the query
        let rows = try await connection.simpleQuery("SELECT * FROM articles WHERE pub_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)ORDER BY pub_date DESC;").get()

        return rows
    }
}


//struct SettingsRowToggleSwitchView: View {
//    var title: String
//    var description: String
//    @Binding var allowPushNotifications: Bool
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                Text(description)
//                    .font(.caption)
//                    .foregroundStyle(Color(.systemGray))
//            }
//            Toggle("", isOn: $allowPushNotifications)
//                .labelStyle(.iconOnly)
//        }
//    }
//}
//
//struct SettingsRowView: View {
//    var imageName: String
//    var title: String
//    var titntColor: Color
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: imageName)
//                .imageScale(.small)
//                .foregroundColor(titntColor)
//                .font(.title)
//            Text(title)
//                .font(.subheadline)
//                .foregroundStyle(.black)
//        }
//    }
//    //Preview: SettingsRowView(imageName: "gear", title: "Version", titntColor: Color(.systemGray))
//}
//
//struct EditDataButton: View {
//    var action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Text("Edit")
//                .font(.subheadline)
//                .foregroundColor(.white)
//                .frame(width: 30, height: 5)
//                .padding()
//                .background(Color(.systemBlue))
//                .cornerRadius(15)
//        }
//        .padding(.horizontal)
//    }
//}
