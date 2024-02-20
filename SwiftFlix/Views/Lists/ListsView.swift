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
    
    @State var presentCreateNewWatchlist: Bool = false
    @State var newWatchListTitle: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedListTab) {
                    Text("Saved")
                        .tag(0)
                    Text("Watched")
                        .tag(1)
                    Text("Watchlist")
                        .tag(2)
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
                } else if selectedListTab == 1{
                    if movieLists.watchedMovies.movies.isEmpty {
                        Spacer()
                        CustomEmptyView(sfSymbolName: "tv.slash",
                                        title: "No Watched Movies",
                                        subheading: "When you add movies you've watched, they'll appear here.")
                        Spacer()
                    } else {
                        MovieListView(movieList: movieLists.watchedMovies.movies)
                    }
                } else {
                    List {
                        Button {
                            presentCreateNewWatchlist = true
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Image(systemName: "plus.app")
                                    .font(.system(size: 20))
                                Text("New Watchlist...")
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.accentColor)
                        }
                        ForEach(movieLists.watchLists.indices, id: \.self) { index in
                            NavigationLink {
                                WatchlistView(watchlist: $movieLists.watchLists[index])
                            } label: {
                                Text(movieLists.watchLists[index].name)
                                    .font(.system(size: 20))
                                    .bold()
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .foregroundColor(.primary)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            DispatchQueue.main.async {
                                movieLists.watchLists.remove(atOffsets: indexSet)
                            }
                        })
                    }
                    .listStyle(.plain)
                    .onAppear {
                        movieLists.loadWatchLists()
                    }
                }
            }
            .navigationTitle("Lists")
            .alert("New Watchlist", isPresented: $presentCreateNewWatchlist) {
                TextField("",
                          text: $newWatchListTitle,
                          prompt: Text("Watchlist Title"))
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    DispatchQueue.main.async {
                        movieLists.watchLists.append(Watchlist(name: newWatchListTitle))
                        movieLists.saveWatchLists()
                    }
                }
            }
        }
    }
}

#Preview {
    ListsView()
        .environmentObject(MovieLists())
}
