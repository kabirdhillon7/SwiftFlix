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
    @State var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    ContentUnavailableView(
                        "",
                        systemImage: "magnifyingglass",
                        description: Text("No search results for \(viewModel.searchQuery)")
                    )
                } else {
                    List {
                        ForEach(viewModel.searchResults) { movie in
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
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchMovies()
                }
            }
            .onChange(of: viewModel.searchQuery) {
                if viewModel.searchQuery.isEmpty {
                    viewModel.searchResults.removeAll()
                } else {
                    Task {
                        await viewModel.searchMovies()
                    }
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
