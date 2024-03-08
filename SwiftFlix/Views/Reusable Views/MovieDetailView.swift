//
//  MovieDetailView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import SwiftUI
import Combine

/// A view responsible for displaying movie information
struct MovieDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var movieLists: MovieLists
    
    @StateObject var viewModel: MovieDetailViewModel
    
    @State var savedButtonTapped = false
    @State var watchedButtonTapped = false
    @State var presentAddToWatchListSheet = false
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
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
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                           switch phase {
                           case .success(let image):
                               image
                                   .resizable()
                                   .frame(width: 185, height: 277.5)
                                   .aspectRatio(contentMode: .fit)
                                   .cornerRadius(10)
                                   .onAppear {
                                       viewModel.moviePosterImage = image
                                   }
                           case .failure(_):
                               ZStack {
                                   RoundedRectangle(cornerRadius: 10)
                                       .foregroundColor(.white.opacity(0.5))
                                       .frame(width: 185, height: 277.5)
                                   Image(systemName: "film")
                                       .font(.system(size: 50))
                                       .foregroundColor(Color(UIColor.lightGray))
                               }
                               .onAppear {
                                   viewModel.moviePosterImage = Image(systemName: "film")
                               }
                           default:
                               ProgressView()
                           }
                       }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: 185, height: 277.5)
                            Image(systemName: "film")
                                .font(.system(size: 50))
                                .foregroundColor(Color(UIColor.lightGray))
                        }
                        .onAppear {
                            viewModel.moviePosterImage = Image(systemName: "film")
                        }
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
                        
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            let savedMovie = movieLists.savedMovies
                            Button(role: .none) {
                                savedButtonTapped.toggle()
                                if savedMovie.contains(viewModel.movie) {
                                    savedMovie.remove(viewModel.movie)
                                } else {
                                    savedMovie.add(viewModel.movie)
                                }
                                DispatchQueue.main.async {
                                    movieLists.objectWillChange.send()
                                }
                            } label: {
                                Image(systemName: savedMovie.contains(viewModel.movie) ? "bookmark.fill" : "bookmark")
                                    .font(.body)
                                    .symbolEffect(.bounce, value: savedButtonTapped)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .sensoryFeedback(.success, trigger: savedButtonTapped)
                            
                            let watchedMovies = movieLists.watchedMovies
                            Button(role: .none) {
                                watchedButtonTapped.toggle()
                                if watchedMovies.contains(viewModel.movie) {
                                    watchedMovies.remove(viewModel.movie)
                                } else {
                                    watchedMovies.add(viewModel.movie)
                                }
                                DispatchQueue.main.async {
                                    movieLists.objectWillChange.send()
                                }
                            } label: {
                                Image(systemName: watchedMovies.contains(viewModel.movie) ? "checkmark.square" : "xmark.square")
                                    .font(.body)
                                    .symbolEffect(.bounce, value: watchedButtonTapped)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .sensoryFeedback(.success, trigger: watchedButtonTapped)
                            
                            Button(role: .none) {
                                presentAddToWatchListSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.body)
                                    .symbolEffect(.bounce, value: presentAddToWatchListSheet)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                            .sensoryFeedback(.success, trigger: presentAddToWatchListSheet)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                
                Text(viewModel.movie.overview)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                
                if let videoID = viewModel.trailerKey {
                    Text("Trailer")
                        .font(.system(size: 21))
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    YouTubePlayerView(videoID: videoID)
                        .frame(height: 250)
                        .padding(.horizontal)
                }
                
                if !viewModel.recommendedMovies.isEmpty {
                    Text("Recommended")
                        .font(.system(size: 21))
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.flexible())], content: {
                            ForEach($viewModel.recommendedMovies.wrappedValue) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    if let posterPath = movie.poster_path {
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .frame(width: 185, height: 277.5)
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(10)
                                            default:
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .frame(width: 185, height: 277.5)
                                                    Image(systemName: "film")
                                                        .font(.system(size: 50))
                                                        .foregroundColor(Color(UIColor.lightGray))
                                                }
                                            }
                                        }
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.white.opacity(0.5))
                                                .frame(width: 185, height: 277.5)
                                            Image(systemName: "film")
                                                .font(.system(size: 50))
                                                .foregroundColor(Color(UIColor.lightGray))
                                        }
                                    }
                                }
                            }
                        })
                        .scenePadding(.leading)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                viewModel.fetchMovieTrailer()
                viewModel.fetchMovieRecommendations()
                
                movieLists.presentDetailMovie = false
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let movieUrl = URL(string: "swiftflix://movie/\(viewModel.movie.id)") {
                        ShareLink(item: movieUrl) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $presentAddToWatchListSheet) {
                NavigationStack {
                    AddToWatchListView(movie: viewModel.movie)
                }
            }
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
        NavigationStack {
            MovieDetailView(movie: sampleMovie)
                .environmentObject(MovieLists())
        }
    }
}
