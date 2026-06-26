//
//  MovieGridView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 11/20/24.
//

import SwiftData
import SwiftUI

struct MovieGridView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass

    let movies: [Movie]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                spacing: 16
            ) {
                ForEach(movies) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        PosterImage(path: movie.posterPath, width: 110)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
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
    NavigationStack {
        MovieGridView(movies: [sampleMovie, sampleMovie, sampleMovie])
    }
}
