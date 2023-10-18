//
//  SavedView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftUI

/// A view responsible for displaying saved movies
struct SavedView: View {
    @EnvironmentObject var savedMoviesViewModel: SavedViewModel
    
    var body: some View {
        NavigationStack {
            if savedMoviesViewModel.savedMovie.movies.isEmpty {
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 75))
                    .foregroundColor(Color(UIColor.lightGray))
                Spacer()
                    .frame(height: 5)
                Text("No Saved Movies")
                    .fontWeight(.medium)
                    .foregroundColor(Color(UIColor.lightGray))
                    .navigationTitle("Saved")
            } else {
                List {
                    ForEach(Array(savedMoviesViewModel.savedMovie.movies), id: \.self) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            HStack {
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 92.5, height: 138.75)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(15)
                                } placeholder: {
                                    ProgressView()
                                }
                                Spacer()
                                    .frame(width: 10)
                                Text(movie.title)
                                    .font(.system(size: 20))
                                    .bold()
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }
                    }
                }
                .navigationTitle("Saved")
            }
        }
        .navigationTitle("Saved")
        .onAppear() {
            DispatchQueue.main.async { }
        }
    }
}

//struct SavedView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedView()
//    }
//}
