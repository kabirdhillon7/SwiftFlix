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
        if let backdropPath = movie.backdropPath, !backdropPath.isEmpty {
            ZStack(alignment: .bottomLeading) {
                Group {
                    CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200, alignment: .center)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .accentColor, location: 0),
                                        .init(color: .clear, location: 0.35)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6))
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    movieTitleText
                }
            }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(UIColor.systemGray6))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.accentColor, .clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .overlay(alignment: .center) {
                    Image(systemName: "film")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .overlay(alignment: .bottomLeading) {
                    movieTitleText
                }
        }
    }
    
    var movieTitleText: some View {
        VStack {
            Text(movie.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .ralewayFont(.headline)
                .lineLimit(1)
                .padding()
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
