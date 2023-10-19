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
                    Label("Now Playing", systemImage: "film")
                }
            SavedView()
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
