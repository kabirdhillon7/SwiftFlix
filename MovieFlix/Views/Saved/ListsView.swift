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
                        List {
                            ForEach(Array(movieLists.savedMovies.movies), id: \.self) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    HStack {
                                        if let posterPath = movie.poster_path {
                                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 92.5, height: 138.75)
                                                    .aspectRatio(contentMode: .fill)
                                                    .cornerRadius(15)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Image(systemName: "photo")
                                        }
                                        Spacer()
                                            .frame(width: 10)
                                        Text(movie.title)
                                            .font(.system(size: 20))
                                            .bold()
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if movieLists.watchedMovies.movies.isEmpty {
                        Spacer()
                        CustomEmptyView(sfSymbolName: "tv.slash",
                                        title: "No Watched Movies",
                                        subheading: "When you add movies you've watched, they'll appear here.")
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(movieLists.watchedMovies.movies), id: \.self) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    HStack {
                                        if let posterPath = movie.poster_path {
                                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 92.5, height: 138.75)
                                                    .aspectRatio(contentMode: .fill)
                                                    .cornerRadius(15)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Image(systemName: "photo")
                                        }
                                        Spacer()
                                            .frame(width: 10)
                                        Text(movie.title)
                                            .font(.system(size: 20))
                                            .bold()
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lists")
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
            .environmentObject(MovieLists())
    }
}
