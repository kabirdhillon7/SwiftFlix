//
//  SearchToAddToWatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftUI

struct SearchToAddToWatchListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var movieLists: MovieLists
    
    @StateObject var viewModel = SearchToAddToWatchListViewModel()
    @Binding var watchlist: Watchlist
    
    var body: some View {
        List {
            ForEach(viewModel.searchResults) { movie in
                HStack(spacing: 5) {
                    if let posterPath = movie.poster_path {
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                            image
                                .resizable()
                                .frame(width: 61, height: 91.5)
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(15)
                                .padding()
                            
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(width: 61, height: 91.5)
                                Image(systemName: "film")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(UIColor.lightGray))
                            }
                        }
                    }
                    
                    VStack(spacing: 5) {
                        Text(movie.title)
                            .font(.system(size: 20))
                            .bold()
                            .frame(maxWidth: .infinity,alignment: .leading)
                        Text(movie.overview) // TODO: Maybe remove
                            .font(.body)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .lineLimit(2)
                    }
                    
                    Button {
                        if viewModel.selectedMovies.contains(movie) {
                            viewModel.selectedMovies.remove(movie)
                        } else {
                            viewModel.selectedMovies.insert(movie)
                        }
                    } label: {
                        Image(systemName: viewModel.selectedMovies.contains(movie) ? "checkmark.circle" : "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, 10)
                }
            }
            .listRowInsets(EdgeInsets())
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
        .interactiveDismissDisabled()
        .listStyle(.plain)
        .navigationTitle("Add to \"\(watchlist.name)\"")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let index = movieLists.watchLists.firstIndex(where: { $0.id == watchlist.id }) {
                        for movie in viewModel.selectedMovies {
                            movieLists.watchLists[index].moviesList.insert(movie)
                        }
                        movieLists.saveWatchLists()
                    }
                    dismiss()
                } label: {
                    Text("Done")
                        .bold()
                }
            }
            
        }
    }
}

//#Preview {
//    SearchToAddToWatchListView()
//}
