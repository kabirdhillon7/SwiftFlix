//
//  MovieListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftUI

/// A view responsible for displaying a list of movies.
struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel
    
    init(movieList: Set<Movie>) {
        _viewModel = StateObject(wrappedValue: MovieListViewModel(movieList: movieList))
    }
    
    var body: some View {
        List {
            ForEach(Array(viewModel.movieList), id: \.self) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    HStack(spacing: 10) {
                        if let posterPath = movie.poster_path {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath))  { phase in
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
                                            .frame(width: 92.5, height: 138.75)
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
                                Image(systemName: "film")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(UIColor.lightGray))
                            }
                        }
                        
                        Text(movie.title)
                            .font(.system(size: 20))
                            .bold()
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    MovieListView(movieList: Set<Movie>())
}
