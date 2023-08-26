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
    var movie: Movie
    @State var trailerKey: String?
    
    private let apiCaller: APICaller = APICaller()
    @State private var cancellables = Set<AnyCancellable>()
    
    @EnvironmentObject var savedMoviesViewModel: SavedViewModel
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 5) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + movie.backdrop_path))
                    .frame(height: 200, alignment: .center)
                    .ignoresSafeArea()
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                    )
                
                HStack {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                        .frame(width: .infinity, height: 277.5)
                    
                    VStack(spacing: 5) {
                        Text(movie.title)
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", movie.vote_average)) / 10")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer(minLength: 10)
                        }
                        
                        let savedMovie = savedMoviesViewModel.savedMovie
                        Button(role: .none) {
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Spacer()
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Text(movie.overview)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if let videoID = trailerKey {
                    YouTubePlayerView(videoID: videoID)
                        .frame(height: 300)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear(perform: getMovieTrailer)
        }
    }
    
    /// Fetches a the movie trailer for a particular movie
    func getMovieTrailer() {
        apiCaller.getMovieTrailer(movieId: movie.id)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { videoID in
                self.trailerKey = videoID
            }
            .store(in: &cancellables)
        
    }
}

//struct MovieDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleMovie = Movie(
//            id: 502356,
//            title: "The Super Mario Bros. Movie",
//            overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
//            poster_path: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
//            backdrop_path: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
//            vote_average: 7.7
//        )
//
//        MovieDetailView(movie: sampleMovie, trailerKey: "RjNcTBXTk4I")
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}
