//
//  ContentView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI
import Combine

/// A view responsible for displaying recently playing movies
struct MovieView: View {
    @StateObject var movieViewModel = MovieViewModel()
    @State private var selectedTab = 0
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Picker("", selection: $selectedTab) {
                    Text("Now Playing")
                        .tag(0)
                    Text("Popular")
                        .tag(1)
                    Text("Upcoming")
                        .tag(2)
                }
                .pickerStyle(.segmented)
                .onAppear(perform: {
                    movieViewModel.fetchNowPlayingMovies()
                    movieViewModel.fetchPopularMovies()
                    movieViewModel.fetchUpcomingMovies()
                })
                
                LazyVGrid(columns: columns, spacing: 0) {
                    if selectedTab == 0 {
                        ForEach(movieViewModel.nowPlayingMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                                } else {
                                    Image(systemName: "photo")
                                }
                            }
                        }
                    } else if selectedTab == 1 {
                        ForEach(movieViewModel.popularMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                                } else {
                                    Image(systemName: "photo")
                                }
                            }
                        }
                    } else {
                        ForEach(movieViewModel.upcomingMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                                } else {
                                    Image(systemName: "photo")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .padding(.horizontal)
        }
    }
}

#Preview {
    MovieView()
}
