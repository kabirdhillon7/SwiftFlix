//
//  MovieGridView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/24/24.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct ExpandedMovieGridView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) var dismiss
    
    let movies: [Movie]
        
    var body: some View {
        MovieGridView(movies: movies)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .ralewayFont(.subheadline)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background {
                                Circle()
                                    .foregroundStyle(.black.opacity(0.2))
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
    NavigationStack {
        ExpandedMovieGridView(movies: [sampleMovie, sampleMovie, sampleMovie])
    }
}
