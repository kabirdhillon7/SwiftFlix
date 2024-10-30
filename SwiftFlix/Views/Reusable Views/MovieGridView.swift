//
//  MovieGridView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/24/24.
//

import SwiftData
import SwiftUI

struct MovieGridView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let movies: [Movie]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0),
                                     count: 3),
                      spacing: 0) {
                ForEach(movies) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        if let posterPath = movie.posterPath, !posterPath.isEmpty {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .aspectRatio(0.67, contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 185, height: 277.5)
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.white.opacity(0.5))
                                Image(systemName: "film")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(UIColor.lightGray))
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleMovie = Movie(
        id: 502356,
        title: "The Super Mario Bros. Movie",
        overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
        posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
        backdropPath: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
        voteAverage: 7.7,
        isWatched: false,
        isBookmarked: false
    )
    MovieGridView(movies: [sampleMovie, sampleMovie, sampleMovie])
}
