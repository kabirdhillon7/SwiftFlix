//
//  MainView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI

struct MainView: View {
    @StateObject private var savedMoviesVM = MovieLists()
    
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
        .environmentObject(savedMoviesVM)
    }
}

#Preview {
    MainView()
}
