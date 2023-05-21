//
//  ContentView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI
import Combine

struct MovieView: View {
    @StateObject var movieViewModel = MovieViewModel()
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(movieViewModel.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                        }
                    }
                    
                }
                .navigationTitle("Now Playing")
                .onAppear {
                    movieViewModel.fetchMovies()
                }
                .padding(.horizontal)
            }
        }
        //.frame(maxHeight: .infinity)
        
        /*
        NavigationStack {
            List(movieViewModel.movies) { movie in
                HStack (alignment: .top) {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                        .frame(maxWidth: UIScreen.main.bounds.width / 3)
                    
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.title2)
                            .bold()
                            
                        Text(movie.overview)
                    }
                }
            }
            .navigationTitle("Now Playing")
            .onAppear {
                movieViewModel.fetchMovies()
            }
        }*/
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView()
    }
}
