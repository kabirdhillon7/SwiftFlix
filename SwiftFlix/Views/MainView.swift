//
//  MainView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData
import SwiftUI

struct MainView: View {
    
    // MARK: Properties
    
//    @State private var container: ModelContainer
    
    // MARK: Init
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Raleway-Bold", size: 35)!]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Raleway-SemiBold", size: 18)!]
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "Raleway-SemiBold", size: 11)! ], for: .normal)
    
//        do {
//            let config = ModelConfiguration(for: Movie.self, WatchListCollection.self)
//            container = try  ModelContainer(for: Movie.self, WatchListCollection.self, configurations: config)
//        } catch {
//            fatalError("Failed to set up the model container: \(error)")
//        }
    }
    
    // MARK: View
    
    var body: some View {
        TabView {
            MovieView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.and.film")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .modelContainer(for: [Movie.self, WatchlistCollection.self])
//        .modelContainer(container)
    }
}

#Preview {
    MainView()
}
