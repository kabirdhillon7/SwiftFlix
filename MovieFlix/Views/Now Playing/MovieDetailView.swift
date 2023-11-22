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
    @EnvironmentObject var savedMoviesViewModel: SavedViewModel
    var movie: Movie
    @State var trailerKey: String?
    
    private let apiCaller: APICaller = APICaller()
    @State private var cancellables = Set<AnyCancellable>()
    
    @State var savedButtonTapped = false
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 5) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + movie.backdrop_path))
                    .frame(height: 200, alignment: .center)
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                    )
                
                HStack {
                    if let posterPath = movie.poster_path{
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))
                            .frame(width: 185, height: 277.5)
                            .cornerRadius(15)
                    } else {
                        Image(systemName: "photo")
                            .frame(width: 185, height: 277.5)
                            .cornerRadius(15)
                    }
                    
                    VStack(spacing: 5) {
                        Text(movie.title)
                            .font(.system(size: 21))
                            .bold()
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", movie.vote_average)) / 10")
                            .font(.system(size: 17))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        let savedMovie = savedMoviesViewModel.savedMovie
                        Button(role: .none) {
                            savedButtonTapped.toggle()
                            if savedMovie.contains(movie) {
                                savedMovie.remove(movie)
                            } else {
                                savedMovie.add(movie)
                            }
                            DispatchQueue.main.async {
                                savedMoviesViewModel.objectWillChange.send()
                            }
                        } label: {
                            Image(systemName: savedMovie.contains(movie) ? "bookmark.fill" : "bookmark")
                                .font(.body)
                                .symbolEffect(.bounce, value: savedButtonTapped)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Text(movie.overview)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if let videoID = trailerKey {
                    YouTubePlayerView(videoID: videoID)
                        .frame(height: 300)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                fetchMovieTrailer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    /// Fetches a the movie trailer for a particular movie
    func fetchMovieTrailer() {
        apiCaller.getMovieTrailer(movieId: movie.id)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error getting movie trailer: \(error)")
                }
            } receiveValue: { videoID in
                self.trailerKey = videoID
            }
            .store(in: &cancellables)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(id: 502356,
                                title: "The Super Mario Bros. Movie",
                                overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
                                poster_path: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
                                backdrop_path: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
                                vote_average: 7.7
        )

        MovieDetailView(movie: sampleMovie, trailerKey: "RjNcTBXTk4I")
            .environmentObject(SavedViewModel())
    }
}
