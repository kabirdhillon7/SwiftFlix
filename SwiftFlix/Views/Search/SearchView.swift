//
//  SearchView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftData
import SwiftUI

/// A view that displays search results for movies
struct SearchView: View {
    @Environment(\.modelContext) var modelContext
//    @State var viewModel = SearchViewModel()
    @State private var searchResults = [Movie]()
    @State private var searchQuery: String = ""
    private let apiCaller = APICaller()
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchResults.isEmpty && !searchQuery.isEmpty {
                    ContentUnavailableView(
                        "",
                        systemImage: "magnifyingglass",
                        description: Text("No search results for \(searchQuery)")
                    )
                } else {
                    List {
                        ForEach(searchResults) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                HStack(spacing: 10) {
                                    if let posterPath = movie.posterPath {
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                            image
                                                .resizable()
                                                .frame(width: 92.5, height: 138.75)
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(10)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 92.5)
                                        }
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.white.opacity(0.5))
                                                .frame(width: 92.5, height: 138.75)
                                            Image(systemName: "film")
                                                .font(.system(size: 50))
                                                .foregroundColor(Color(UIColor.lightGray))
                                        }
                                    }
                                    
                                    VStack(spacing: 5) {
                                        Text(movie.title)
                                            .font(.system(size: 20))
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2)
                                        Text(movie.overview)
                                            .font(.body)
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                            .lineLimit(4)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                Task {
                    await searchMovies()
                }
            }
            .onChange(of: searchQuery) {
                if searchQuery.isEmpty {
                    searchResults.removeAll()
                } else {
                    Task {
                        await searchMovies()
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
        }
    }
    
    @MainActor
    func searchMovies() async {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(APIInformation.key.rawValue)&query=\(encodedQuery)"
        
        do {
            searchResults = try await apiCaller.getData(urlString: urlString, decoderType: MovieResults.self).results
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SearchView()
}
