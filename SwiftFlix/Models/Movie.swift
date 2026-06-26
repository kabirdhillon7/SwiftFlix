//
//  Movie.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation
import SwiftData

struct MovieResults: Decodable, Equatable {
    let results: [MovieDTO]
}

struct MovieDTO: Decodable, Equatable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let runtime: Int?

    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        releaseDate: String?,
        runtime: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.runtime = runtime
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }

    func makeMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate,
            runtime: runtime,
            recentlyViewedAt: nil,
            isWatched: false,
            isBookmarked: false
        )
    }
}

@Model
final class Movie: Identifiable, Hashable {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double
    var releaseDate: String?
    var runtime: Int?
    var recentlyViewedAt: Date?
    var isWatched: Bool
    var isBookmarked: Bool

    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        releaseDate: String? = nil,
        runtime: Int? = nil,
        recentlyViewedAt: Date? = nil,
        isWatched: Bool,
        isBookmarked: Bool
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.recentlyViewedAt = recentlyViewedAt
        self.isWatched = isWatched
        self.isBookmarked = isBookmarked
    }

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func update(with dto: MovieDTO) {
        title = dto.title
        overview = dto.overview
        posterPath = dto.posterPath
        backdropPath = dto.backdropPath
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
        runtime = dto.runtime ?? runtime
    }
}

enum MovieSortOption: String, CaseIterable, Identifiable {
    case title
    case rating
    case releaseYear

    var id: Self { self }

    var title: String {
        switch self {
        case .title:
            return "Title"
        case .rating:
            return "Rating"
        case .releaseYear:
            return "Year"
        }
    }
}

enum WatchlistSortOption: String, CaseIterable, Identifiable {
    case title
    case count

    var id: Self { self }

    var title: String {
        switch self {
        case .title:
            return "Title"
        case .count:
            return "Count"
        }
    }
}

extension Array where Element == Movie {
    func sorted(by option: MovieSortOption) -> [Movie] {
        switch option {
        case .title:
            return sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .rating:
            return sorted {
                if $0.voteAverage == $1.voteAverage {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.voteAverage > $1.voteAverage
            }
        case .releaseYear:
            return sorted {
                if $0.releaseYear == $1.releaseYear {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.releaseYear > $1.releaseYear
            }
        }
    }

    var recentlyViewed: [Movie] {
        filter { $0.recentlyViewedAt != nil }
            .sorted { ($0.recentlyViewedAt ?? .distantPast) > ($1.recentlyViewedAt ?? .distantPast) }
    }
}

extension Array where Element == Watchlist {
    func sorted(by option: WatchlistSortOption) -> [Watchlist] {
        switch option {
        case .title:
            return sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .count:
            return sorted {
                if $0.movies.count == $1.movies.count {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.movies.count > $1.movies.count
            }
        }
    }
}

extension Movie {
    var releaseYear: Int {
        guard let releaseDate,
              let yearString = releaseDate.split(separator: "-").first,
              let year = Int(yearString) else {
            return 0
        }
        return year
    }

    var releaseYearText: String? {
        releaseYear == 0 ? nil : String(releaseYear)
    }

    var runtimeText: String? {
        guard let runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours == 0 {
            return "\(minutes)m"
        }
        return minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)m"
    }
}

extension ModelContext {
    func movie(matching dto: MovieDTO) -> Movie {
        if let existing = existingMovie(id: dto.id) {
            existing.update(with: dto)
            return existing
        }

        let movie = dto.makeMovie()
        insert(movie)
        return movie
    }

    func movies(matching dtos: [MovieDTO]) -> [Movie] {
        dtos.map { movie(matching: $0) }
    }

    func existingMovie(id: Int) -> Movie? {
        var descriptor = FetchDescriptor<Movie>(
            predicate: #Predicate<Movie> { movie in
                movie.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try? fetch(descriptor).first
    }

    func markRecentlyViewed(_ movie: Movie, limit: Int = 12) {
        movie.recentlyViewedAt = Date()

        var descriptor = FetchDescriptor<Movie>()
        descriptor.fetchLimit = 100
        let movies = (try? fetch(descriptor)) ?? []
        let overflow = movies.recentlyViewed.dropFirst(limit)

        for movie in overflow {
            movie.recentlyViewedAt = nil
        }

        try? save()
    }
}
