//
//  MainView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MovieView()
                .tabItem {
                    Label("Now Playing", systemImage: "film")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // Saved Movies
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
