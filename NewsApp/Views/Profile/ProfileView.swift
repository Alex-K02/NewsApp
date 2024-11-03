//
//  ProfileView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 19.09.24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataService: CoreDataService
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var articleListViewModel: ArticlesListViewModel
    @EnvironmentObject private var eventsListViewModel: EventsListViewModel

    @State private var articles: [Article] = []
    @State private var events: [Event] = []
    @State private var userId: String?
    @State private var user: User?
    @State private var userPreferences: UserPreference?
    
    @State private var isLoading = true
    @State private var showProfileEditPage = false
    @State private var allowPushNotifications = false
    @State private var showPopUp = false
    @State private var isMarked = true
    
    @State private var selectedTab: String = "Articles"
    //user preference params
    @State private var article: Article?
    @State private var domain: String?
    @State private var author = ""
    @State private var event: Event?

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading...").onAppear {
                    Task { await loadUserData() }
                }
            } else {
                if let userId = userId, let user = user {
                    ZStack {
                        VStack {
                            ProfileHeaderView(user: user)
                            EditProfileButtonView(showProfileEdit: $showProfileEditPage)
                            CustomPickerView(selectedTab: $selectedTab)
                            // Load view based on selected tab
                            contentForSelectedTab(userPreference: userPreferences ?? nil)
                        }

                        if showPopUp {
                            if let userPreferences = userPreferences {
                                MiddlePopUpView(
                                    text: "Are you sure you want to delete this favorite?",
                                    isPopUpActive: $showPopUp,
                                    content: MiddlePopUpFavoriteContentView(userPreference: userPreferences, isPopUpActive: $showPopUp, article: article, author: author, domain: domain ?? "", event: event)
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                    .sheet(isPresented: $showProfileEditPage) {
                        EditProfileView()
                            .onDisappear {
                                Task { await reloadUserData() }
                            }
                    }
                } else {
                    // Navigate to login view if user is not logged in
                    LoginView()
                }
            }
        }
        .task {
            await loadArticles()
        }
    }

    private func ProfileHeaderView(user: User) -> some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.black)

            Text(user.name ?? "")
                .foregroundColor(.black)
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Text(user.email ?? "")
                    .font(.subheadline)
                    .accentColor(.black)
                Image(systemName: "checkmark.circle")
                    .imageScale(.small)
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }

    private func contentForSelectedTab(userPreference: UserPreference?) -> some View {
        switch selectedTab {
        case "Articles":
            return AnyView(articleContentView(userPreference: userPreference ?? nil))
        case "Sites":
            return AnyView(siteContentView())
        case "Authors":
            return AnyView(authorContentView())
        case "Events":
            return AnyView(eventContentView(userPreference: userPreference ?? nil))
        default:
            return AnyView(Text("Invalid selection"))
        }
    }
    
    // MARK: - ContentViews of all Sections
    private func eventContentView(userPreference: UserPreference?) -> some View {
        let isFavoriteListEmpty = (userPreference?.preference?.eventIDs.isEmpty ?? true)
        let eventIDs = userPreference?.preference?.eventIDs ?? []

        return VStack {
            if eventsListViewModel.isLoading {
                ProgressView("Loading articles...")
            } else if events.isEmpty {
                Text("No events found.")
                    .padding()
            } else {
                if isFavoriteListEmpty {
                    Text("No favorite events found.")
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(eventIDs, id: \.self) { id in
                            if let event = events.first(where: { $0.id?.uuidString == id }) {
                                ProfileEventBlockView(showPopUp: $showPopUp, event: event, onDelete: {
                                    self.event = event
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .background(isFavoriteListEmpty ? Color(.white) : Color(red: 242/256, green: 242/256, blue: 247/256))
    }
    
    private func articleContentView(userPreference: UserPreference?) -> some View {
        VStack {
            if articleListViewModel.isLoading {
                VStack {
                    ProgressView("Loading articles...")
                }
            } else if articles.isEmpty {
                VStack {
                    Text("No articles found.")
                        .padding()
                }
            } else {
                if userPreference?.preference?.articleIDs.count == 0 {
                    Text("No favorite articles found.")
                        .padding()
                    Spacer()
                }
                else {
                    ScrollView {
                        ForEach(userPreference?.preference?.articleIDs ?? [], id: \.self) { id in
                            if let article = articles.first(where: { $0.id?.uuidString == id }) {
                                ProfileArticleBlockView(showPopUp: $showPopUp, article: article) {
                                    self.article = article
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .background(userPreference?.preference?.articleIDs.isEmpty == true ? Color(.white) : Color(red: 242/256, green: 242/256, blue: 247/256))
    }
    
    private func siteContentView() -> some View {
        ScrollView {
            if userPreferences?.preference?.domains.count == 0 {
                Text("No favorite articles found.")
                    .padding()
            }
            else {
                VStack(alignment: .leading) {
                    ForEach(userPreferences?.preference?.domains ?? [], id: \.self) { domain in
                        ProfileDomainBlockView(showPopUp: $showPopUp, addingDate: Date(), domain: domain) {
                            self.domain = domain
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .frame(minWidth: 100, maxWidth: .infinity)
        .background(userPreferences?.preference?.domains.count == 0 ? Color(.white) : Color(red: 242/256, green: 242/256, blue: 247/256))
    }

    private func authorContentView() -> some View {
        VStack {
            if userPreferences?.preference?.authors.count == 0 {
                ScrollView {
                    Text("No favorite authors found.")
                        .padding()
                }
            }
            else {
                List(userPreferences?.preference?.authors ?? [], id: \.self) { author in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(author)
                            Text("This is a sample review.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            showPopUp = true
                            self.author = author
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - LoadFunctions
    private func loadArticles() async {
        do {
            articles = articleListViewModel.articles
            events = eventsListViewModel.events
            if articles.isEmpty {
                articles = await articleListViewModel.fetchArticles()
            }
            if events.isEmpty {
                events = await eventsListViewModel.fetchEvents()
            }
        }
        catch {
            print(error.localizedDescription)
        }
        articleListViewModel.isLoading = false
    }

    func loadUserData() async {
        // Load JWT and check if user is logged in
        authViewModel.loadJWTFromKeychain()
        guard let loadedUserId = authViewModel.loadIdValue(token: authViewModel.userJWTSessionToken), authViewModel.isUserLoggedIn() else {
            self.isLoading = false
            return
        }
        userId = loadedUserId
        do {
            user = try await coreDataService.extractDataFromCoreData().first(where: { $0.id?.uuidString == userId })
            userPreferences = try await coreDataService.extractDataFromCoreData().first(where: { $0.id?.uuidString == userId })
        }
        catch {
            print("No data was extracted from Core Data")
        }
        // Load user and preferences from Core Data
        isLoading = false
    }

    func reloadUserData() async {
        isLoading = true
        await loadUserData()
    }
}


// MARK: - User Extension

extension User {
    var intials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: self.name!) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var domain: String? = "example.com"
    ProfileView()
}

