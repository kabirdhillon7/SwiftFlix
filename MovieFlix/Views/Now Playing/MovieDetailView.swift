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
                    .frame(height: 225, alignment: .center)
                    .scaledToFill()
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .center, endPoint: .bottom)
                    )

                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + movie.poster_path))
                    .frame(width: 185, height: 277.5)

                Text(movie.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Image(systemName: "star.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.yellow)

                    Text(String(format: "%.1f", movie.vote_average) + " / 10")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                }
                
                Text(movie.overview)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }.frame(width: UIScreen.main.bounds.width)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(
            id: 502356,
            title: "The Super Mario Bros. Movie",
            overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
            poster_path: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
            backdrop_path: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
            vote_average: 7.7
        )
        
        MovieDetailView(movie: sampleMovie)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
