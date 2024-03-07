//
//  SearchView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftUI
import Combine

/// A view that displays search results for movies
struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack(spacing: 10) {
                            if let posterPath = movie.poster_path {
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 92.5, height: 138.75)
                                            .aspectRatio(contentMode: .fit)
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
                                        .frame(width: 92.5, height: 138.75)
//                                        .padding()
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
//                .listRowInsets(EdgeInsets())
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                viewModel.searchMovies()
            }
            .onChange(of: viewModel.searchQuery) {
                if viewModel.searchQuery.isEmpty {
                    viewModel.searchResults.removeAll()
                } else {
                    viewModel.searchMovies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
    
}

// MARK: Hides the Keyboard When Not In Use
extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
