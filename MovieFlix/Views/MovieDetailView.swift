//
//  MovieDetailView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/19/23.
//

import SwiftUI

struct MovieDetailView: View {
    var movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + movie.backdrop_path))
                    .frame(height: 150)
                    .scaledToFill()
                    .clipped()
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                    )
                    .scaledToFill()
                
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                    .frame(width: 150, height: 225)
                                
                Text(movie.title)
                    .font(.title)
                    .bold()
                    //.fixedSize(horizontal: false, vertical: true)
                
                Text(movie.overview)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    //.fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(
            id: 123456,
            title: "The Super Mario Bros. Movie",
            overview: "This is a placeholder overview for The Super Mario Bros. Movie.",
            poster_path: "/super_mario_bros_poster.jpg",
            backdrop_path: "/super_mario_bros_backdrop.jpg",
            vote_average: 7.8
        )
        
        MovieDetailView(movie: sampleMovie)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
