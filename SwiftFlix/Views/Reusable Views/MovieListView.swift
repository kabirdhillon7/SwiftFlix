//
//  MovieListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import CachedAsyncImage
import SwiftUI

struct MovieListView: View {
    let movies: [Movie]

    init(movieList: Set<Movie>) {
        self.movies = movieList.sorted { $0.title < $1.title }
    }

    var body: some View {
        List(movies) { movie in
            NavigationLink {
                MovieDetailView(movie: movie)
            } label: {
                MovieListRow(movie: movie)
            }
        }
        .listStyle(.plain)
    }
}

struct MovieListRow: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(path: movie.posterPath, width: 78)

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .ralewayFont(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(movie.overview.isEmpty ? "No overview available." : movie.overview)
                    .ralewayFont(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                    .ralewayFont(.caption, weight: .medium)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
    }
}

struct PosterImage: View {
    let path: String?
    let width: CGFloat

    private var height: CGFloat {
        width * 1.5
    }

    var body: some View {
        Group {
            if let path, !path.isEmpty {
                CachedAsyncImage(url: TMDBImage.poster(path: path, width: .w185)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    default:
                        ProgressView()
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 10, y: 6)
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            Image(systemName: "film")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

enum TMDBImage {
    enum PosterWidth: String {
        case w185
        case w342
        case w500
    }

    enum BackdropWidth: String {
        case w780
        case w1280
    }

    static func poster(path: String, width: PosterWidth) -> URL? {
        URL(string: "https://image.tmdb.org/t/p/\(width.rawValue)\(path)")
    }

    static func backdrop(path: String, width: BackdropWidth) -> URL? {
        URL(string: "https://image.tmdb.org/t/p/\(width.rawValue)\(path)")
    }
}

#Preview {
    MovieListView(movieList: Set<Movie>())
}
