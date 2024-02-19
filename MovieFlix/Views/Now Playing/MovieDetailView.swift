//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import SwiftUI
import Combine

/// A view responsible for displaying movie information
struct MovieDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var savedMoviesViewModel: MovieLists
    
    @StateObject var viewModel: MovieDetailViewModel
    
    @State var savedButtonTapped = false
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                if let backdropPath = viewModel.movie.backdrop_path {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath))
                        .frame(height: 200, alignment: .center)
                        .mask(
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                        )
                } else {
                    Rectangle()
                        .frame(height: 200, alignment: .center)
                        .foregroundStyle(.clear)
                }
                
                HStack {
                    if let posterPath = viewModel.movie.poster_path {
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                            .frame(width: 185, height: 277.5)
                            .cornerRadius(15)
                    } else {
                        Image(systemName: "film")
                            .frame(width: 185, height: 277.5)
                            .cornerRadius(15)
                    }
                    
                    VStack(spacing: 5) {
                        Text(viewModel.movie.title)
                            .font(.system(size: 21))
                            .bold()
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", viewModel.movie.vote_average)) / 10")
                            .font(.system(size: 17))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        let savedMovie = savedMoviesViewModel.savedMovies
                        Button(role: .none) {
                            savedButtonTapped.toggle()
                            if savedMovie.contains(viewModel.movie) {
                                savedMovie.remove(viewModel.movie)
                            } else {
                                savedMovie.add(viewModel.movie)
                            }
                            DispatchQueue.main.async {
                                savedMoviesViewModel.objectWillChange.send()
                            }
                        } label: {
                            Image(systemName: savedMovie.contains(viewModel.movie) ? "bookmark.fill" : "bookmark")
                                .font(.body)
                                .symbolEffect(.bounce, value: savedButtonTapped)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .sensoryFeedback(.success, trigger: savedButtonTapped)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Text(viewModel.movie.overview)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if let videoID = viewModel.trailerKey {
                    YouTubePlayerView(videoID: videoID)
                        .frame(height: 300)
                }
                
                Spacer()
                
                if !viewModel.recommendedMovies.isEmpty {
                    Text("Recommended")
                        .font(.system(size: 21))
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(height: 5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.flexible())], content: {
                            ForEach($viewModel.recommendedMovies.wrappedValue) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    if let posterPath = movie.poster_path {
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                                            .frame(width: 185, height: 277.5)
                                            .cornerRadius(15)
                                    } else {
                                        Image(systemName: "film")
                                            .frame(width: 185, height: 277.5)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        })
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                viewModel.fetchMovieTrailer()
                viewModel.fetchMovieRecommendations()
            }
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(.primary)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(
            id: 502356,
            title: "The Super Mario Bros. Movie",
            overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
            poster_path: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
            backdrop_path: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
            vote_average: 7.7
        )
        
        MovieDetailView(movie: sampleMovie)
            .environmentObject(MovieLists())
    }
}
