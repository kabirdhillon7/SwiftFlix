//
//  MovieDetailView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import SwiftData
import SwiftUI

/// A view responsible for displaying movie information
struct MovieDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    
//    @State private var viewModel: ViewModel
    @Bindable var movie: Movie
    
    @State private(set) var trailerKey: String?
    @State private(set) var watchProviderLinkString: String?
    @State private(set) var recommendedMovies = [Movie]()
    @State private(set) var movieCredits: Credits?
    
    private let apiCaller = APICaller()

    @State var savedButtonTapped = false
    @State var watchedButtonTapped = false
    @State var presentRecommendedList = false
    @State var presentAddToWatchListSheet = false
    @State var presentWatchListViewSheet = false
    
//    init(movie: Movie, modelContext: ModelContext) {
//        _viewModel = State(
//            wrappedValue: ViewModel(
//                movie: movie,
//                modelContext: modelContext,
//                apiCaller: APICaller()
//            )
//        )
//    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                backdropImage
                
                HStack {
                    posterImage
                    VStack(spacing: 5) {
                        Text(movie.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Image(systemName: "star.fill")) \(String(format: "%.1f", movie.voteAverage)) / 10")
                            .font(.headline.weight(.medium))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        buttonView
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                Text(movie.overview)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                trailerView
                watchView
                creditView
                recommendedView
            }
            .frame(width: UIScreen.main.bounds.width)
            .onAppear {
                Task {
                    await fetchMovieTrailer()
                    await fetchMovieRecommendations()
                    await fetchWatchProviderLink()
                    await fetchCredits()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $presentRecommendedList) {
                MovieGridView(movies: recommendedMovies)
            }
//            .sheet(isPresented: $presentAddToWatchListSheet) {
//                NavigationStack {
//                    AddToWatchListView(movie: viewModel.movie)
//                }
//            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var backdropImage: some View {
        VStack {
            if let backdropPath = movie.backdropPath {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200, alignment: .center)
                        .mask(
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                        )
                } placeholder: {
                    Rectangle()
                        .frame(height: 200, alignment: .center)
                        .foregroundStyle(.clear)
                }
            } else {
                Rectangle()
                    .frame(height: 200, alignment: .center)
                    .foregroundStyle(.clear)
            }
        }
    }
    
    var posterImage: some View {
        VStack {
            if let posterPath = movie.posterPath {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 185, height: 277.5)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 185, height: 277.5)
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
    
    var buttonView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Button(role: .none) {
                movie.isBookmarked.toggle()
                savedButtonTapped.toggle()
            } label: {
                Image(systemName: movie.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(movie.isBookmarked ? .green : .accentColor)
                    .font(.body)
            }
            .contentTransition(.symbolEffect(.replace))
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .sensoryFeedback(.success, trigger: savedButtonTapped)
            
            Button(role: .none) {
                movie.isWatched.toggle()
                watchedButtonTapped.toggle()
            } label: {
                Image(systemName: movie.isWatched ? "checkmark.square" : "xmark.square")
                    .foregroundStyle(movie.isWatched ? .green : .accentColor)
                    .font(.body)
            }
            .contentTransition(.symbolEffect(.replace))
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .sensoryFeedback(.success, trigger: watchedButtonTapped)
            
//            Button(role: .none) {
//                presentAddToWatchListSheet = true
//            } label: {
//                Image(systemName: "plus")
//                    .font(.body)
//                    .symbolEffect(.bounce, value: presentAddToWatchListSheet)
//            }
//            .buttonStyle(.bordered)
//            .buttonBorderShape(.circle)
//            .sensoryFeedback(.success, trigger: presentAddToWatchListSheet)
            
            Spacer()
        }
    }
    
    var trailerView: some View {
        VStack {
            if let videoID = trailerKey {
                Text("Trailer")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                YouTubePlayerView(videoID: videoID)
                    .frame(height: 250)
                    .padding(.horizontal)
            }
        }
    }
    
    var watchView: some View {
        VStack {
            if let watchProviderLinkString = watchProviderLinkString, !watchProviderLinkString.isEmpty, let watchProviderLinkUrl = URL(string: watchProviderLinkString)  {
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
        }
    }
    
    var creditView: some View {
        VStack {
            if let credits = movieCredits {
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
                                            ProgressView()
                                                .frame(width: 120, height: 120)
//                                            ZStack {
//                                                Circle()
//                                                    .foregroundColor(.white.opacity(0.5))
//                                                    .frame(width: 120, height: 120)
//                                                Image(systemName: "person.fill")
//                                                    .font(.system(size: 50))
//                                                    .foregroundColor(Color(UIColor.lightGray))
//                                                    .padding()
//                                            }
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
        }
    }
    
    var recommendedView: some View {
        VStack {
            if !recommendedMovies.isEmpty {
                HStack {
                    Text("Recommended")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Spacer()
                    Button {
                        presentRecommendedList.toggle()
                    } label: {
                        Text("See all")
                            .foregroundStyle(.gray)
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(recommendedMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                if let posterPath = movie.posterPath {
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
                                            ProgressView()
                                                .frame(width: 185, height: 277.5)
//                                            ZStack {
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .foregroundColor(.white.opacity(0.5))
//                                                    .frame(width: 185, height: 277.5)
//                                                Image(systemName: "film")
//                                                    .resizable()
//                                                    .font(.system(size: 50))
//                                                    .foregroundColor(Color(UIColor.lightGray))
//                                            }
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
    }
    
    /// Fetches a the movie trailer for a particular movie
    @MainActor
    func fetchMovieTrailer() async {
        do {
            trailerKey = try await apiCaller.getMovieTrailer(movieId: movie.id)
        } catch {
            print("Error getting movie trailer: \(error)")
        }
    }
    
    /// Fetches a list of recommended movies for a particular movie
    @MainActor
    func fetchMovieRecommendations() async {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)/recommendations?api_key=\(APIInformation.key.rawValue)"
        
        do {
            let fetchedMovies = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
            for movie in fetchedMovies where !recommendedMovies.contains(movie) {
                modelContext.insert(movie)
            }
            recommendedMovies = fetchedMovies
        } catch {
            print("Error getting recommended movies: \(error)")
        }
    }
    
    /// Fetches a watch provider link for a particular movie
    @MainActor
    func fetchWatchProviderLink() async {
        do {
            watchProviderLinkString = try await apiCaller.getWatchProviders(movieID: movie.id)
        } catch {
            print("Error getting watch provider link: \(error)")
        }
    }
    
    /// Fetches the credits for a particular movie
    @MainActor
    func fetchCredits() async {
        let urlString = "https://api.themoviedb.org/3/movie/\(movie.id)/credits?api_key=\(APIInformation.key.rawValue)"
        
        do {
            movieCredits = try await apiCaller.getData(urlString: urlString, decoderType: Credits.self)
        } catch {
            print("Error getting credits: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Movie.self, configurations: config)
            let sampleMovie = Movie(
                id: 502356,
                title: "The Super Mario Bros. Movie",
                overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
                posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
                backdropPath: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
                voteAverage: 7.7,
                isWatched: false,
                isBookmarked: false
            )
            
            return MovieDetailView(movie: sampleMovie)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }
}

