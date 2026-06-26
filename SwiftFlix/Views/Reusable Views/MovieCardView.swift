//
//  MovieCardView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/24/24.
//

import CachedAsyncImage
import SwiftUI

struct MovieCardView: View {

    let movie: Movie

    var body: some View {
        Group {
            if let backdropPath = movie.backdropPath, !backdropPath.isEmpty {
                ZStack(alignment: .bottomLeading) {
                    Group {
                        CachedAsyncImage(url: TMDBImage.backdrop(path: backdropPath, width: .w780)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                placeholder
                            default:
                                ZStack {
                                    placeholder
                                    ProgressView()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(cardGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .overlay(alignment: .bottomLeading) {
                        movieTitleText
                    }
                    .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
                }
            } else {
                placeholder
                    .frame(maxWidth: .infinity)
                    .overlay(cardGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        movieTitleText
                    }
                    .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
    }

    var movieTitleText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(movie.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .ralewayFont(.headline)
                .lineLimit(2)
            Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                .ralewayFont(.caption, weight: .medium)
                .foregroundStyle(.orange)
        }
        .padding()
    }

    private var cardGradient: some View {
        LinearGradient(
            colors: [.black.opacity(0.68), .black.opacity(0.08), .clear],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
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
    MovieCardView(movie: sampleMovie)
}

#Preview {
    let sampleMovie2 = Movie(
        id: 502356,
        title: "The Super Mario Bros. Movie",
        overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
        posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
        backdropPath: "",
        voteAverage: 7.7,
        isWatched: false,
        isBookmarked: false
    )
    MovieCardView(movie: sampleMovie2)
}
