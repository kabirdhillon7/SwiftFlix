//
//  ContentView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftData
import SwiftUI

/// A view responsible for displaying recently playing movies
struct MovieView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
//    @State var viewModel: ViewModel
    private let apiCaller = APICaller()
    
    @State private var nowPlayingMovies = [Movie]()
    @State private var popularMovies = [Movie]()
    @State private var upcomingMovies = [Movie]()
    
    @State private var presentNowPlayingList: Bool = false
    @State private var presentPopularList: Bool = false
    @State private var presentUpcomingList: Bool = false
    
//    init(modelContext: ModelContext) {
//        _viewModel = State(
//            initialValue: ViewModel(
//                modelContext: modelContext,
//                apiCaller: APICaller()
//            )
//        )
//    }
        
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    nowPlayingHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(nowPlayingMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                        .modelContext(modelContext)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        Task {
                            await fetchNowPlayingMovies()
                        }
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                    .padding(.bottom, 10)
                    
                    popularHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(popularMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                        .modelContext(modelContext)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        Task {
                            await fetchPopularMovies()
                        }
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                    .padding(.bottom, 10)
                    
                    upcomingHeader
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(upcomingMovies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                        .modelContext(modelContext)
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
                    .onAppear(perform: {
                        Task {
                            await fetchUpcomingMovies()
                        }
                    })
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .scrollIndicators(.hidden)
                }
                .navigationTitle("Movies")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(isPresented: $presentNowPlayingList, destination: {
                    MovieGridView(movies: nowPlayingMovies)
                        .padding(.horizontal)
                })
                .navigationDestination(isPresented: $presentPopularList, destination: {
                    MovieGridView(movies: popularMovies)
                        .padding(.horizontal)
                })
                .navigationDestination(isPresented: $presentUpcomingList, destination: {
                    MovieGridView(movies: upcomingMovies)
                        .padding(.horizontal)
                })
            }
        }
    }
    
    var nowPlayingHeader: some View {
        HStack {
            Text("Now Playing")
                .ralewayFont(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentNowPlayingList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .ralewayFont(.footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
    
    var popularHeader: some View {
        HStack {
            Text("Popular")
                .ralewayFont(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentPopularList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .ralewayFont(.footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
    
    var upcomingHeader: some View {
        HStack {
            Text("Upcoming")
                .ralewayFont(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            Spacer()
            Button {
                presentUpcomingList.toggle()
            } label: {
                Text("See all")
                    .foregroundStyle(.gray)
                    .ralewayFont(.footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
        }
    }
    
    @MainActor
    func fetchNowPlayingMovies() async {
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=\(APIInformation.key.rawValue)"
        do {
            let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
            for movie in fetchedMovies where !nowPlayingMovies.contains(where: { $0.id == movie.id }) {
                modelContext.insert(movie)
            }
            nowPlayingMovies = fetchedMovies
        } catch {
            print("Error getting now playing movies: \(error)")
        }
    }
    
    /// Fetches a list of movies now playing in theaters
    @MainActor
    func fetchPopularMovies() async {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(APIInformation.key.rawValue)"
        do {
            let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
            for movie in fetchedMovies where !popularMovies.contains(where: { $0.id == movie.id }) {
                modelContext.insert(movie)
            }
            popularMovies = fetchedMovies.filter {
                !nowPlayingMovies.contains($0) &&
                !upcomingMovies.contains($0)
            }
        } catch {
            print("Error getting now playing movies: \(error)")
        }
    }
    
    /// Fetches a list of movies upcoming in theaters
    @MainActor
    func fetchUpcomingMovies() async {
        let urlString = "https://api.themoviedb.org/3/movie/upcoming?api_key=\(APIInformation.key.rawValue)"
        do {
            let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
            for movie in fetchedMovies where !upcomingMovies.contains(where: { $0.id == movie.id }) {
                modelContext.insert(movie)
            }
            upcomingMovies = fetchedMovies.filter {
                !nowPlayingMovies.contains($0) &&
                !popularMovies.contains($0)
            }
        } catch {
            print("Error getting now playing movies: \(error)")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Movie.self, configurations: config)
        return MovieView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
    }
}
