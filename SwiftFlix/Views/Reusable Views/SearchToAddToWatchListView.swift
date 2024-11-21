//
//  SearchToAddToWatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct SearchToAddToWatchListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    //    @EnvironmentObject var movieLists: MovieLists
    
    @StateObject var viewModel = SearchToAddToWatchListViewModel()
    @Bindable var watchlist: Watchlist
    
    @State private var searchResults = [Movie]()
    @State private var searchQuery: String = ""
    private let apiCaller = APICaller()
    @FocusState private var keyboardFocus: Bool
    
    @State private var selectedMovies = [Movie]()
    var addedMovies: ([Movie]) -> Void
    
    //    init(watchlist: Watchlist) {
    //        self.watchlist = watchlist
    //    }
    
    var body: some View {
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
            
            if searchResults.isEmpty && !searchQuery.isEmpty {
                ContentUnavailableView.search
            } else {
                List {
                    ForEach(searchResults) { movie in
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
                            
                            Button {
                                addMovie(movie)
                            } label: {
                                Image(systemName: watchlist.movies.contains(movie) ? "checkmark.circle" : "plus.circle")
                                    .ralewayFont(.body, size: 20, weight: .medium)
                                    .foregroundColor(watchlist.movies.contains(movie) ? .green : .accentColor)
                            }
//                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .navigationTitle("Add to \"\(watchlist.title)\"")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .listStyle(.plain)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    keyboardFocus = false
                } label: {
                    Text("Done")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                        .ralewayFont(.body, size: 16, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .bold()
                        .foregroundStyle(.primary)
                        .ralewayFont(.body, size: 16, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
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
    
    func addMovie(_ movie: Movie) {
        if watchlist.movies.contains(movie) {
            guard let index = watchlist.movies.firstIndex(where: { $0 == movie }) else { return }
            watchlist.movies.remove(at: index)
            
        } else {
            watchlist.movies.append(movie)
        }
        try? modelContext.save()
    }
}

//#Preview {
//    SearchToAddToWatchListView()
//}
