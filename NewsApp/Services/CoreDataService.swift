//
//  CoreDataService.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 02.09.24.
//

import Foundation
import CoreData
import SwiftUI

enum SignInResult {
    case success(message: String)
    case failure(message: String)
}

class CoreDataService: ObservableObject {
    private var viewContext: NSManagedObjectContext
    private let passHelper = PassHelper()
    private let authViewModel = AuthViewModel()
    
    private var syncTask: Task<Void, Never>?
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    public func printCoreDataStoreLocation() {
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Unresolved error \(error), \(error.localizedDescription)")
            } else {
                if let url = storeDescription.url {
                    print("Core Data store URL: \(url.absoluteString)")
                }
            }
        }
    }
    
    public func loadEvents(eventsListViewModel: EventsListViewModel) async throws -> [Event] {
        var fetchedEvents: [Event] = []
        fetchedEvents = try await self.extractDataFromCoreData() as [Event]
        if fetchedEvents.isEmpty {
            fetchedEvents = await eventsListViewModel.fetchEvents()
        }
        fetchedEvents = fetchedEvents.sorted { event1, event2 in
            guard let date1 = event1.start_date else { return false }
            guard let date2 = event2.start_date else { return true }
            return date1 > date2
        }
        return fetchedEvents
    }
    
    public func uploadEvents(with jsonEventsData: Data) async throws -> [Event] {
        var events: [Event] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        do {
            let fetchedEvents = try await self.extractDataFromCoreData() as [Event]
            let fetchedEventsID = Set(fetchedEvents.map {$0.id})
            
            var newEventsCount = 0
            
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonEventsData, options: .fragmentsAllowed) as? [[String: Any]] {
                for jsonObject in jsonArray {
                    // check that id exists and that is not already stored
                    guard let eventID = jsonObject["event_id"] as? String, !fetchedEventsID.contains(UUID(uuidString: eventID)) else { continue }
                    
                    let event = Event(context: self.viewContext)
                    event.id = UUID(uuidString: eventID)
                    
                    guard let startDate = jsonObject["start_date"] as? String,
                          let endDate = jsonObject["end_date"] as? String,
                          let parsedStartDate = dateFormatter.date(from: startDate),
                          let parsedEndDate = dateFormatter.date(from: endDate) else
                    {
                        print("skipped article: \(eventID)")
                        continue
                    }
                    
                    
                    event.title = jsonObject["title"] as? String
                    event.start_date = parsedStartDate
                    event.end_date = parsedEndDate
                    event.location = jsonObject["location"] as? String
                    event.event_type = jsonObject["event_type"] as? String
                    event.topics = jsonObject["topics"] as? String
                    event.speakers = jsonObject["speakers"] as? String
                    event.link = jsonObject["link"] as? String
                    event.registration_link = jsonObject["registration_link"] as? String
                    event.summary = jsonObject["description"] as? String
                    event.price = jsonObject["price"] as? String
                    event.sponsors = jsonObject["sponsors"] as? String
                    //
                    newEventsCount += 1
                    events.append(event)
                }
                print("New fetched Events: \(newEventsCount)")
            }
            else {
                print("Data is not in expected JSON array format.")
            }
            
            if newEventsCount != 0 {
                await viewContext.perform {
                    do {
                        try self.viewContext.save() // Save the context to persist data
                        print("Successfully saved events to Core Data.")
                    } catch {
                        print("Failed to save events to Core Data: \(error.localizedDescription)")
                    }
                }
            }
        }
        catch {
            throw error
        }
        
        return events
    }
    
    //MARK: - ExtractingData
    
    func fetchUserById(userId: String) async throws -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userId)
        let result = try viewContext.fetch(request)
        return result.first
    }
    
    public func extractDataFromCoreData<T: NSManagedObject>() async throws -> [T] {
        return await viewContext.perform {
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else {
                print("Failed to create fetch request")
                return []
            }
            do {
                let data = try self.viewContext.fetch(fetchRequest)
                return data
            } catch {
                print("Failed to fetch data: \(error) + \(error.localizedDescription)")
                return []
            }
        }
    }
    
    //MARK: - Article Evaluation and Sorting
    func evaluateArticles(newArticles: [Article]) async throws -> [(score: Double, article: Article)] {
        var articleScores:[(score: Double, article: Article)] = []
        // Load user session
        authViewModel.loadJWTFromKeychain()
        
        if let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken),
            authViewModel.isUserLoggedIn() {
            let userId = loadedUserId
            
            // Extract user preferences from CoreData
            let allUserPreferences = try await extractDataFromCoreData() as [UserPreference]
            guard let userPreference = allUserPreferences.first(where: { $0.id?.uuidString == userId }) else {
                print("User preference not found")
                return []
            }
            
            var userPrefernceArticle: [Article] = []
            
            // Fetch preferred articles
            if let articleIDs = userPreference.preference?.articleIDs, !articleIDs.isEmpty {
                //fetching all articles
                let allArticles = try await extractDataFromCoreData() as [Article]
                
                for articleID in articleIDs {
                    
                    if let article = allArticles.first(where: { $0.id?.uuidString == articleID }) {
                        userPrefernceArticle.append(article)
                    }
                }
                
                //sort articles from new to old
                let sortedNewArticles = newArticles.sorted {
                    if let date1 = $0.pubDate, let date2 = $1.pubDate {
                        return date1 > date2
                    }
                    return false
                }
                
                // Evaluate articles
                do {
                    articleScores = try await evaluateArticle(sortedNewArticles, usersPreferencedArticles: userPrefernceArticle)
                    print("Evaluated \(articleScores.count) article scores.")
                }
                catch {
                    print("Some error occurred while evaluating articles.")
                    throw error
                }
            }
        }
        
        return articleScores
    }
    
    public func evaluateArticle(_ articles: [Article], usersPreferencedArticles: [Article]) async throws -> [(score: Double, article: Article)] {
        var articleScores: [(score: Double, article: Article)] = []
        if !usersPreferencedArticles.isEmpty {
            let articleSummaries = try await extractDataFromCoreData() as [ArticleSummary]
            let setArticleSummaries = Set(articleSummaries)
            //going through all user favorite articles
            for usersPreferencedArticle in usersPreferencedArticles {
                for summary in setArticleSummaries {
                    var score = 0.0
                    //checking not to evaluate articles that are already selected as favorite
                    if usersPreferencedArticles.contains(where: {$0.id == summary.id}) {
                        continue
                    }
                    //evaluating current article with one of the favorite articles
                    if let articleSummary = setArticleSummaries.first(where: {$0.id == summary.id}),
                       let userPreferencesArticleSummary = setArticleSummaries.first(where: {$0.id == usersPreferencedArticle.id}),
                       let currentArticle = articles.first(where: {$0.id == summary.id}) {
                        score += try await findMatchings(userArticleSummary: articleSummary.titles ?? "", articleSummary: userPreferencesArticleSummary.titles  ?? "", scoreIncrement: 1.0)
                        score += try await findMatchings(userArticleSummary: articleSummary.concepts ?? "", articleSummary: userPreferencesArticleSummary.concepts  ?? "", scoreIncrement: 3.0)
                        score += try await findMatchings(userArticleSummary: articleSummary.entities ?? "", articleSummary: userPreferencesArticleSummary.entities  ?? "", scoreIncrement: 2.0)
                        score += try await findMatchings(userArticleSummary: articleSummary.terms ?? "", articleSummary: userPreferencesArticleSummary.terms  ?? "", scoreIncrement: 1.0)
                        score += try await findMatchings(userArticleSummary: articleSummary.subterms ?? "", articleSummary: userPreferencesArticleSummary.subterms  ?? "", scoreIncrement: 0.5)
                        
                        // check if article is already in array then add scores and
                        if let index = articleScores.firstIndex(where: { $0.article.id == currentArticle.id }) {
                            articleScores[index].score += score / 5
                        } else {
                            // Add new article with its score
                            articleScores.append((score: score / 5, article: currentArticle))
                        }
                    }
                }
            }
            
            for (index, var articleScore) in articleScores.enumerated() {
                articleScore.score /= Double(usersPreferencedArticles.count)
                articleScores[index] = articleScore
            }
        }
        return articleScores
    }
    
    func sortByDateAndScore(articles: [(score: Double, article: Article)]) async throws -> [(score: Double, article: Article)] {
        //for the case when score has more priority
        return articles.sorted {
            // First, sort by score in descending order
            if $0.score != $1.score {
                return $0.score > $1.score
            }

            // If scores are the same, sort by pubDate in descending order
            if let date1 = $0.article.pubDate, let date2 = $1.article.pubDate {
                return date1 > date2
            }

            // In case both score and pubDate are nil or the same, return false (no reordering)
            return false
        }
    }
    //for the case when the date has more priority
//         return articles.sorted {
//            if let date1 = $0.article.pubDate, let date2 = $1.article.pubDate {
//                // First, sort by pubDate in descending order
//                if date1 != date2 {
//                    return date1 > date2
//                }
//            }
//            // If pubDate is the same, sort by score in descending order
//            return $0.score > $1.score
//        }
    
    
    private func findMatchings(userArticleSummary: String, articleSummary: String, scoreIncrement: Double) async throws -> Double {
        var score = 0.0
        
        let formattedArticleSummary = articleSummary.split(separator: ",")
        
        for keyWord in formattedArticleSummary {
            if userArticleSummary.contains(keyWord.trimmingCharacters(in: .whitespacesAndNewlines)) {
                score += scoreIncrement
            }
        }
        return score / Double(formattedArticleSummary.count)
    }
    
    
    func checkUniqueArticles(articles: [Article]) async throws -> [Article] {
        let articlesFromCoreData = try await self.extractDataFromCoreData() as [Article]
        var newArticles: [Article] = []
        
        for article in articles {
            if !articlesFromCoreData.contains(where: { $0.link == article.link }) {
                newArticles.append(article)
            }
        }
        return newArticles
    }
    
    //MARK: - PeriodicDataSync
    func enablePeriodicDataSync(articleListViewModel: ArticlesListViewModel) async throws {
        syncTask = Task {
            var lastSyncTime: String = "2024-08-24 11:27:00"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            while !Task.isCancelled { // Check if the task has been cancelled
                let fetchedArticles = await articleListViewModel.fetchArticles(lastSyncTime: lastSyncTime)
                
                do {
                    let articleScores = try await evaluateArticles(newArticles: fetchedArticles)
                    let sortedArticles = try await sortByDateAndScore(articles: articleScores)
                    if let sortedArticle = sortedArticles.first {
                        NotificationManager.shared.dispatchNotification(identifier: UUID().uuidString, title: "New Article: \(sortedArticle.article.title ?? "No Title")", body: sortedArticle.article.descrip ?? "No description", timeInterval: 60.0)
                    }
                }
                catch {
                    print("Error with fetching new articles: \(error.localizedDescription)")
                }
                
                lastSyncTime = dateFormatter.string(from: Date())
                print("I am keep fetching articles...")
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000) // Sleep for 5 minutes
            }
        }
    }
    
    func disablePeriodicDataSync() async {
        syncTask?.cancel() // Cancel the task to stop fetching
        syncTask = nil
        print("I stopped fetching articles...")
    }
    
    //MARK: - HandlingUserInput
    
    func removeUserPrefernces(userPreference: UserPreference?, article: Article?=nil, domain: String?="", author: String?="", event: Event?=nil) async {
        await viewContext.perform {
            guard let userPreference = userPreference, let userId = userPreference.id else {
                print("Invalid user preference or user ID")
                return
            }
            
            let request: NSFetchRequest<UserPreference> = UserPreference.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
            
            do {
                let usersPreferences = try self.viewContext.fetch(request)
                
                if let currentUserPreference = usersPreferences.first, let currentPreference = currentUserPreference.preference {
                    
                    var domains = currentPreference.domains
                    var authors = currentPreference.authors
                    var articleIDs = currentPreference.articleIDs
                    var eventIDs = currentPreference.eventIDs
                    
                    // Remove author if provided and exists
                    if let author = author, let authorIndex = authors.firstIndex(of: author) {
                        authors.remove(at: authorIndex)
                    }
                    
                    // Remove domain if provided and exists
                    if let domain = domain, let domainIndex = domains.firstIndex(of: domain) {
                        domains.remove(at: domainIndex)
                    }
                    
                    // Remove article ID if provided and exists
                    if let article = article, let articleId = article.id?.uuidString, let articleIdIndex = articleIDs.firstIndex(of: articleId) {
                        articleIDs.remove(at: articleIdIndex)
                    }
                    
                    if let event = event, let eventId = event.id?.uuidString, let eventIdIndex = eventIDs.firstIndex(of: eventId) {
                        eventIDs.remove(at: eventIdIndex)
                    }
                    
                    // Update the preference object
                    let updatedPreference = Preferences(domains: domains, authors: authors, articleIDs: articleIDs, eventIDs: eventIDs)
                    currentUserPreference.preference = updatedPreference
                    
                    // Save the changes to Core Data
                    try self.viewContext.save()
                    print("User preferences successfully updated by removing items")
                    
                } else {
                    print("No user preferences found")
                }
            } catch {
                print("Failed to remove article from preferences: \(error)")
            }
        }
    }
    
    func saveUserPreferences(userPreference: UserPreference?, article: Article?=nil, domain: String?="", author: String?="", event: Event?=nil) async {
        guard let userPreference = userPreference, let userId = userPreference.id else {
            print("Invalid user preference or user ID")
            return
        }
        
        do {
            // Extract data from Core Data asynchronously
            let usersPreferences = try await self.extractDataFromCoreData() as [UserPreference]
            
            // Now enter the perform block for synchronous Core Data updates
            await viewContext.perform {
                if let currentUserPreference = usersPreferences.first, let currentPreference = currentUserPreference.preference {
                    
                    // Safely update preference properties
                    var domains = currentPreference.domains
                    var authors = currentPreference.authors
                    var articleIDs = currentPreference.articleIDs
                    var eventIDs = currentPreference.eventIDs
                    
                    if let author = author, !author.isEmpty {
                        authors.append(author)
                    }
                    
                    if let domain = domain, !domain.isEmpty {
                        domains.append(domain)
                    }
                    
                    if let article = article, let articleId = article.id?.uuidString, !articleId.isEmpty {
                        articleIDs.append(articleId)
                    }
                    
                    if let event = event, let eventId = event.id?.uuidString, !eventId.isEmpty {
                        eventIDs.append(eventId)
                    }
                    
                    
                    // Update preference
                    let newPreference = Preferences(domains: domains, authors: authors, articleIDs: articleIDs, eventIDs: eventIDs)
                    currentUserPreference.preference = newPreference
                }
                
                // Save changes to Core Data
                do {
                    try self.viewContext.save()
                    print("User Preferences are successfully updated")
                } catch {
                    print("Failed to save user preferences: \(error)")
                }
            }
            
        } catch {
            print("Failed to extract data from Core Data: \(error)")
        }
    }
    
    public func saveUserData(user: User, email: String, dateOfBirth: Date, password: String?) async {
        await viewContext.perform {
            if !email.isEmpty && dateOfBirth != Date() {
                user.email = email.lowercased()
            }
            if dateOfBirth != Date() {
                user.dateOfBirth = dateOfBirth
            }
            if let password = password {
                let salt = self.passHelper.generateSalt()
                let saltedPassword = self.passHelper.hashPassword(password: password, salt: salt)
                user.password = saltedPassword
                user.salt = salt
            }
            do {
                try self.viewContext.save() // Save the context to persist data
                print("Successfully saved data to Core Data.")
            } catch {
                print("Failed to save articles to Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    public func handleUserRegistration(email: String, name: String, dateOfBirth: Date, password: String) async -> SignInResult {
        do {
            let userPreference = Preferences(domains: [], authors: [], articleIDs: [], eventIDs: [])
            
            // Fetch existing users asynchronously
            let fetchedUser = try await self.extractDataFromCoreData() as [User]
            
            // Extract emails
            let fetchedUserMails = Set(fetchedUser.map { $0.email })
            
            // Check if email is already registered
            if !fetchedUserMails.contains(email) {
                let salt = passHelper.generateSalt()
                let saltedPassword = passHelper.hashPassword(password: password, salt: salt)
                
                // Create UserPreference entity
                let userPrefernce = UserPreference(context: viewContext)
                
                // Create User entity
                let userEntity = User(context: viewContext)
                userEntity.id = UUID()
                
                // Set the one-to-one relationship between user and preferences
                userPrefernce.id = userEntity.id
                userPrefernce.preference = userPreference
                userEntity.userIdPreference = userPrefernce
                
                // Set other user attributes
                userEntity.email = email
                userEntity.name = name
                userEntity.dateOfBirth = dateOfBirth
                userEntity.salt = salt
                userEntity.password = saltedPassword
                
                do {
                    try viewContext.save() // Save the context to persist data
                    print("Successfully saved user data!")
                    return .success(message: "Registration successful!")
                } catch {
                    print("Failed to save user data: \(error.localizedDescription)")
                    return .failure(message: "Error: Data could not be saved.")
                }
            } else {
                return .failure(message: "This email is already registered.")
            }
            
        } catch {
            print("Failed to fetch users or process registration: \(error.localizedDescription)")
            return .failure(message: "Error during user registration.")
        }
    }

    
    public func signInCheck(email: String, password: String, rememberMe: Bool) async -> SignInResult {
        do {
            // Fetch users asynchronously
            let fetchedUsers = try await self.extractDataFromCoreData() as [User]
            
            // Create a dictionary to search users by email
            let userDictionary = Dictionary(uniqueKeysWithValues: fetchedUsers.map { ($0.email, $0) })
            
            // Check if the user exists and verify the password
            if let user = userDictionary[email] {
                if passHelper.verifyPassword(password, hashedPasswordWithSalt: user.password!) {
                    authViewModel.logIn(user: user, rememberMe: rememberMe)
                    return .success(message: "Login successful!")
                } else {
                    return .failure(message: "Entered password is not correct!")
                }
            } else {
                return .failure(message: "No account with this email!")
            }
        } catch {
            return .failure(message: "An error occurred while signing in: \(error.localizedDescription)")
        }
    }
    
    public func uploadArticlesToCoreData(jsonArticles: Data) async -> [Article] {
        var newArticles: [Article] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        do {
            // Fetch articles asynchronously using the Task method
            let fetchedArticles = try await self.extractDataFromCoreData() as [Article]
            let fetchedArticleIDs = Set(fetchedArticles.map { $0.id })

            // Decode JSON and ensure it's in the expected format
            guard let jsonArray = try JSONSerialization.jsonObject(with: jsonArticles, options: .fragmentsAllowed) as? [[String: Any]] else {
                print("Data is not in expected JSON array format.")
                return []
            }

            var amountOfNewArticles = 0

            for jsonObject in jsonArray {
                // Check if the article is unique by its ID
                guard let currentIDString = jsonObject["article_id"] as? String,
                      let articleUUID = UUID(uuidString: currentIDString),
                      !fetchedArticleIDs.contains(articleUUID) else {
                    continue
                }

                // Parse publication and download dates
                guard let pubDate = jsonObject["pub_date"] as? String,
                      let downDate = jsonObject["down_date"] as? String,
                      let parsedPubDate = dateFormatter.date(from: pubDate),
                      let parsedDownDate = dateFormatter.date(from: downDate) else {
                    continue // Skip invalid entries
                }

                // Create Article entity
                let articleEntity = Article(context: self.viewContext)
                articleEntity.id = articleUUID
                articleEntity.title = jsonObject["title"] as? String
                articleEntity.author = jsonObject["author"] as? String
                articleEntity.pubDate = parsedPubDate
                articleEntity.link = jsonObject["link"] as? String
                articleEntity.maintext = jsonObject["main_content"] as? String
                articleEntity.descrip = jsonObject["description"] as? String
                articleEntity.domain = jsonObject["domain"] as? String
                articleEntity.downDate = parsedDownDate

                // Create ArticleSummary entity
                let articleSummaryEntity = ArticleSummary(context: self.viewContext)
                articleSummaryEntity.id = articleUUID
                articleSummaryEntity.titles = jsonObject["titles"] as? String
                articleSummaryEntity.concepts = jsonObject["concepts"] as? String
                articleSummaryEntity.entities = jsonObject["entities"] as? String
                articleSummaryEntity.terms = jsonObject["terms"] as? String
                articleSummaryEntity.subterms = jsonObject["sub_terms"] as? String

                // Link Article and ArticleSummary
                articleEntity.articleSummaryId = articleSummaryEntity

                newArticles.append(articleEntity)
                amountOfNewArticles += 1
            }

            // Print the number of new articles processed
            print("New articles added: \(amountOfNewArticles)")

            // Save Core Data context
            if amountOfNewArticles != 0 {
                try self.viewContext.save()
                print("Successfully saved articles to Core Data.")
            }
            else {
                print("No new articles")
            }
        } catch {
            print("Failed to process articles: \(error.localizedDescription)")
        }

        return newArticles
    }
}
