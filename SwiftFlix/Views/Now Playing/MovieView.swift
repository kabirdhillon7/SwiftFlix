//
//  ContentView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI
import Combine

/// A view responsible for displaying recently playing movies
struct MovieView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var movieLists: MovieLists
    @StateObject var movieViewModel = MovieViewModel()
    @State private var selectedTab = 0
        
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
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0),
                                         count: verticalSizeClass == .regular ? 2 : 3),
                          spacing: 0) {
                    if selectedTab == 0 {
                        ForEach(movieViewModel.nowPlayingMovies) { movie in
                            NavigationLink {
                                MovieDetailView(movie: movie)
                            } label: {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipped()
                                        case .failure(_):
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor(.white.opacity(0.5))
                                                    .frame(width: 185, height: 277.5)
                                                Image(systemName: "film")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(Color(UIColor.lightGray))
                                            }
                                        default:
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                    } else if selectedTab == 1 {
                        ForEach(movieViewModel.popularMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipped()
                                        case .failure(_):
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor(.white.opacity(0.5))
                                                    .frame(width: 185, height: 277.5)
                                                Image(systemName: "film")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(Color(UIColor.lightGray))
                                            }
                                        default:
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        ForEach(movieViewModel.upcomingMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.poster_path {
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipped()
                                        case .failure(_):
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor(.white.opacity(0.5))
                                                    .frame(width: 185, height: 277.5)
                                                Image(systemName: "film")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(Color(UIColor.lightGray))
                                            }
                                        default:
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: movieLists.presentDetailMovie, {
                if let movieId = movieLists.linkedDetailMovieId {
                    movieViewModel.fetchMovieObject(movieId: movieId)
                }
            })
            .alert(isPresented: $movieViewModel.presentLinkError) {
                Alert(title: Text("Error: Unable to Open Movie Details"),
                      message: Text("We couldn't find a movie with the provided movie ID. Please check the URL and try again."))
            }
            .alert(isPresented: $movieLists.presentLinkError) {
                Alert(title: Text("Error: Unable to Open Movie Details"),
                      message: Text("We couldn't find a movie with the provided movie ID. Please check the URL and try again."))
            }
            .navigationDestination(isPresented: $movieViewModel.presentDetailViewForLink, destination: {
                if let movie = movieViewModel.linkedMovie {
                    MovieDetailView(movie: movie)
                }
            })
            .navigationTitle("Movies")
            .padding(.horizontal)
        }
    }
}

#Preview {
    MovieView()
        .environmentObject(MovieLists())
}
