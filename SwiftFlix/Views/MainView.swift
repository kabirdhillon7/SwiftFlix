//
//  MainView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI

struct MainView: View {
    // MARK: Properties
    @StateObject private var movieLists = MovieLists()
    @State var currentTab: SwiftFlixTab = .movies
    
    // MARK: View
    var body: some View {
        TabView(selection: $currentTab) {
            MovieView()
                .tag(SwiftFlixTab.movies)
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            ListsView()
                .tag(SwiftFlixTab.lists)
                .tabItem {
                    Label("Lists", systemImage: "list.and.film")
                }
            SearchView()
                .tag(SwiftFlixTab.search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .environmentObject(movieLists)
        .onOpenURL(perform: { url in
            print("Url: \(url)")
            handleURL(url)
        })
    }
    
    /// Processes a deep link URL to navigate the app or display movie details.
    func handleURL(_ url: URL) {
        guard url.scheme == "swiftflix" else {
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid Url")
            return
        }
        
        guard let host = components.host else {
            return
        }
        
        switch host {
        case "movies":
            currentTab = .movies
        case "lists":
            currentTab = .lists
        case "search":
            currentTab = .search
        case "movie":
            movieLists.presentDetailMovie = true
            
            let path = components.path.replacingOccurrences(of: "/", with: "")
            if path.isNumericOnly {
                movieLists.linkedDetailMovieId = Int(path)
            } else {
                movieLists.presentLinkError = true
            }
            
            currentTab = .movies
        default:
            print("Invalid Url Host")
            break
        }
    }
}

enum SwiftFlixTab: String {
    case movies = "movies"
    case lists = "lists"
    case search = "search"
    case movie = "movie"
}

extension String {
    var isNumericOnly: Bool {
        return allSatisfy { $0.isNumber }
    }
}

#Preview {
    MainView()
}
