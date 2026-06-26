//
//  MainView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI
import SwiftData

struct MainView: View {
    init() {
        if let largeTitleFont = UIFont(name: "Raleway-Bold", size: 35),
           let titleFont = UIFont(name: "Raleway-SemiBold", size: 18),
           let tabFont = UIFont(name: "Raleway-SemiBold", size: 11) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitleFont]
            UINavigationBar.appearance().titleTextAttributes = [.font: titleFont]
            UITabBarItem.appearance().setTitleTextAttributes([.font: tabFont], for: .normal)
        }
    }

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
        .scrollAwareTabBar()
        .modelContainer(for: [Movie.self, Watchlist.self, WatchlistCollection.self])
    }
}

#Preview {
    MainView()
}
