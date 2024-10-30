//
//  MainView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData
import SwiftUI

struct MainView: View {
    
    @State private var container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(for: Movie.self)
            container = try  ModelContainer(for: Movie.self, configurations: config)
        } catch {
            fatalError("Failed to set up the model container: \(error)")
        }
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
        .modelContainer(container)
    }
}

#Preview {
    MainView()
}
