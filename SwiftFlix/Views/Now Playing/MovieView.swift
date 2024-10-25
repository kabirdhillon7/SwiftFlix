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
    @State var movieViewModel = MovieViewModel()
    @State private var selectedTab = 1
    
    @State private var presentNowPlayingList: Bool = false
    @State private var presentPopularList: Bool = false
    @State private var presentUpcomingList: Bool = false
        
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    nowPlayingHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(movieViewModel.nowPlayingMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        movieViewModel.fetchNowPlayingMovies()
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                    
                    popularHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(movieViewModel.filteredPopularMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        movieViewModel.fetchPopularMovies()
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                    
                    upcomingHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(movieViewModel.filteredUpcomingMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        movieViewModel.fetchUpcomingMovies()
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                }
                .navigationTitle("Movies")
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
                .navigationDestination(isPresented: $presentNowPlayingList, destination: {
                    MovieGridView(movies: movieViewModel.nowPlayingMovies)
                })
                .navigationDestination(isPresented: $presentPopularList, destination: {
                    MovieGridView(movies: movieViewModel.filteredPopularMovies)
                })
                .navigationDestination(isPresented: $presentUpcomingList, destination: {
                    MovieGridView(movies: movieViewModel.filteredUpcomingMovies)
                })
                .navigationDestination(isPresented: $movieViewModel.presentDetailViewForLink, destination: {
                    if let movie = movieViewModel.linkedMovie {
                        MovieDetailView(movie: movie)
                    }
                })
            }
        }
    }
    
    var nowPlayingHeader: some View {
        HStack {
            Text("Now Playing")
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentNowPlayingList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
    
    var popularHeader: some View {
        HStack {
            Text("Popular")
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentPopularList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
    
    var upcomingHeader: some View {
        HStack {
            Text("Upcoming")
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentUpcomingList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MovieView()
        .environmentObject(MovieLists())
}
