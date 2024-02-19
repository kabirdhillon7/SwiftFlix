//
//  MainView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var savedMoviesVM = SavedViewModel()
    
    var body: some View {
        TabView {
            MovieView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            ListsView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .environmentObject(savedMoviesVM)
    }
}

#Preview {
    MainView()
}
