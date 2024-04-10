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
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var movieLists: MovieLists
    
    @StateObject var viewModel: MovieDetailViewModel
    
    @State var savedButtonTapped = false
    @State var watchedButtonTapped = false
    @State var presentAddToWatchListSheet = false
    @State var presentWatchListViewSheet = false
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let backdropPath = viewModel.movie.backdrop_path {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200, alignment: .center)
                                .mask(
                                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                                )
                        case .failure(_):
                            Rectangle()
                                .frame(height: 200, alignment: .center)
                                .foregroundStyle(.clear)
                        default:
                            Rectangle()
                                .frame(height: 200, alignment: .center)
                                .foregroundStyle(.clear)
                        }
                    }
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
                                   .aspectRatio(contentMode: .fit)
                                   .frame(width: 185, height: 277.5)
                                   .cornerRadius(10)
                           case .failure(_):
                               ZStack {
                                   RoundedRectangle(cornerRadius: 10)
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
                    
                    VStack(spacing: 5) {
                        Text(viewModel.movie.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", viewModel.movie.vote_average)) / 10")
                            .font(.headline.weight(.medium))
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
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    YouTubePlayerView(videoID: videoID)
                        .frame(height: 250)
                        .padding(.horizontal)
                }
                
                if let watchProviderLinkString = viewModel.watchProviderLinkString, !watchProviderLinkString.isEmpty, let watchProviderLinkUrl = URL(string: watchProviderLinkString)  {
                    Text("Watch")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Text("Seaming information provided by JustWatch.")
                        .font(.footnote.weight(.light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Link(destination: watchProviderLinkUrl, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.accentColor)
                                .padding(.horizontal)
                            Text("View Watch Providers")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                        }
                    })
                }
                
                if let credits = viewModel.movieCredits {
                    Text("Cast & Crew")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(credits.cast, id: \.id) { cast in
                                VStack {
                                    if let profilePath = cast.profilePath {
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + profilePath)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 120, height: 120)
                                                    .clipShape(Circle())
                                            case .failure(_):
                                                ZStack {
                                                    Circle()
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .frame(width: 120, height: 120)
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 50))
                                                        .foregroundColor(Color(UIColor.lightGray))
                                                }
                                            default:
                                                ZStack {
                                                    Circle()
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .frame(width: 120, height: 120)
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 50))
                                                        .foregroundColor(Color(UIColor.lightGray))
                                                        .padding()
                                                }
                                            }
                                        }
                                        .containerRelativeFrame(.horizontal,
                                                                count: verticalSizeClass == .regular ? 3 : 5,
                                                                spacing: 10)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1.0 : 0.75)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        }
                                    } else {
                                        ZStack {
                                            Circle()
                                                .foregroundColor(.white.opacity(0.5))
                                                .frame(width: 120, height: 120)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(Color(UIColor.lightGray))
                                                .padding()
                                        }
                                    }
                                    Text(cast.name)
                                        .frame(width: 120)
                                        .frame(alignment: .center)
                                        .lineLimit(1)
                                    Text(cast.character)
                                        .frame(width: 120)
                                        .frame(alignment: .center)
                                        .font(.footnote)
                                        .lineLimit(1)
                                }
                            }

                        }
                        .scenePadding(.leading)
                    }
                    .scrollIndicators(.hidden)
                }
                
                if !viewModel.recommendedMovies.isEmpty {
                    Text("Recommended")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach($viewModel.recommendedMovies.wrappedValue) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    if let posterPath = movie.poster_path {
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 185, height: 277.5)
                                                    .cornerRadius(10)
                                            case .failure(_):
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .frame(width: 185, height: 277.5)
                                                    Image(systemName: "film")
                                                        .resizable()
                                                        .font(.system(size: 50))
                                                        .foregroundColor(Color(UIColor.lightGray))
                                                }
                                            default:
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(.white.opacity(0.5))
                                                        .frame(width: 185, height: 277.5)
                                                    Image(systemName: "film")
                                                        .resizable()
                                                        .font(.system(size: 50))
                                                        .foregroundColor(Color(UIColor.lightGray))
                                                }
                                            }
                                        }
                                        .containerRelativeFrame(.horizontal,
                                                                count: verticalSizeClass == .regular ? 2 : 4,
                                                                spacing: 10)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1.0 : 0.75)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        }
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                        .scenePadding(.leading)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                viewModel.fetchMovieTrailer()
                viewModel.fetchMovieRecommendations()
                viewModel.fetchWatchProviderLink()
                viewModel.fetchCredits()
                
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
