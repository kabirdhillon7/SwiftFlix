//
//  ListsView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftUI

/// A view responsible for displaying movie lists
struct ListsView: View {
    @EnvironmentObject var movieLists: MovieLists
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedListTab: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedListTab) {
                    Text("Saved")
                        .tag(0)
                    Text("Watched")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedListTab == 0 {
                    if movieLists.savedMovies.movies.isEmpty {
                        Spacer()
                        CustomEmptyView(sfSymbolName: "bookmark",
                                        title: "No Saved Movies",
                                        subheading: "When you add movies to your saved list, they'll appear here.")
                        Spacer()
                    } else {
                        MovieListView(movieList: movieLists.savedMovies.movies)
                    }
                } else {
                    if movieLists.watchedMovies.movies.isEmpty {
                        Spacer()
                        CustomEmptyView(sfSymbolName: "tv.slash",
                                        title: "No Watched Movies",
                                        subheading: "When you add movies you've watched, they'll appear here.")
                        Spacer()
                    } else {
                        MovieListView(movieList: movieLists.watchedMovies.movies)
                    }
                }
            }
            .navigationTitle("Lists")
        }
    }
}

#Preview {
    ListsView()
        .environmentObject(MovieLists())    
}
