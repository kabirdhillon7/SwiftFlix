//
//  SearchView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftData
import SwiftUI
import CachedAsyncImage

/// A view that displays search results for movies
struct SearchView: View {
    @Environment(\.modelContext) var modelContext
//    @State var viewModel = SearchViewModel()
    @State private var searchResults = [Movie]()
    @State private var searchQuery: String = ""
    private let apiCaller = APICaller()
    @FocusState private var keyboardFocus: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("", text: $searchQuery, prompt: Text("Search movies"))
                    .textFieldStyle(RoundedTextField())
                    .focused($keyboardFocus)
                    .padding(.horizontal)
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                    .onSubmit {
                        if !searchQuery.isEmpty {
                            Task {
                                await searchMovies()
                            }
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
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button {
                                keyboardFocus = false
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                        
                if searchResults.isEmpty && !searchQuery.isEmpty {
                    ContentUnavailableView.search
                } else {
                    List {
                        ForEach(searchResults) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                HStack(spacing: 10) {
                                    if let posterPath = movie.posterPath {
                                        CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
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
                                            .ralewayFont(.title)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2)
                                        Text(movie.overview)
                                            .ralewayFont(.body)
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                            .lineLimit(4)
                                        Spacer()
                                    }
                                }
                            }
                        }
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
