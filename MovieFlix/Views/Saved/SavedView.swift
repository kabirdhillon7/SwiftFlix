//
//  SavedView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftUI

/// A view responsible for displaying bookmarked movies
struct SavedView: View {
    @EnvironmentObject var savedMoviesViewModel: SavedViewModel
    
    var body: some View {
        NavigationStack {
            if savedMoviesViewModel.savedMovie.movies.isEmpty {
                Text("No Saved Movies")
                    .navigationTitle("Saved")
            } else {
                List {
                    ForEach(Array(savedMoviesViewModel.savedMovie.movies), id: \.self) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            HStack {
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                                Text(movie.title)
                                    .bold()
                            }
                        }
                    }
                }
                .navigationTitle("Saved")
            }
        }
        .navigationTitle("Saved")
        .onAppear() {
            DispatchQueue.main.async {
                
            }
        }
    }
}

//struct SavedView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedView()
//    }
//}
