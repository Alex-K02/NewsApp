# NewsApp "AboutIT"

This app is a personalized platform for discovering and managing IT industry news and events, customized to match user interests. It uses an external Scraper Module (from a separate repository) to gather and store data in a central database. This data is accessible through an easy-to-use API, enabling dynamic updates within the app. Key features include personalized user preferences, secure data storage, and an AI-powered event parsing system to keep users updated with the latest relevant content.

## Main Functionality
### Core Data Integration
* Comprehensive Data Structure: Core Data setup includes all necessary tables and dependencies, enabling efficient data management and storage.
### API Integration
* Data Flow and Access: API calls enable the transfer of scraped articles into Core Data and retrieval for in-app display, providing a seamless user experience.
### Authentication
* Secure Sign-In and Sign-Up: JWT-based authentication, implemented with **KeychainSwift**, supports secure access to personalized features.
* Sensitive Data Protection: Uses hashed values with added salts to protect user passwords and other sensitive information.
### UI Design
* Main Page: An intuitive main screen layout, connected to Core Data, allows users to easily browse articles.
* Article Detail Page: A detailed view for each article, designed to enhance readability and engagement.

## Extended Functionality
### User Preferences
* Account Page: Displays user preferences, including favorite publishers and authors, with options for easy management and deletion.
* Favorites Management: A dedicated favorites page where users can mark items with hearts, view lists of preferred authors and domains, and use popover menus for quick selection.
* Priority-Based Output: Personalized content suggestions based on user priorities, tailored to show what matters most to each user.
### Notification
* Push Notifications: Custom alerts notify users about new articles and events based on their interests and preferences.
Continuous Content Updates
* Automated Article Fetching: A background method checks every 5 minutes for new articles, keeping content fresh and relevant.
* Content Relevance Analysis: New articles are analyzed and prioritized based on user preferences, ensuring the most relevant content is shown first.

## Event Functionality
### Event Management and Display
* Event Page Design: A dedicated interface for users to explore and manage event details.
* Liked Events: An option to "like" events and delete them from the account page as needed.
* Event Parsing and Storage: AI-driven modules parse event data and store it in a Core Data structure dedicated to events.
* Async Event Requests: Runs asynchronously with article requests to ensure efficient data handling.
