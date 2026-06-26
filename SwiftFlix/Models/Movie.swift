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

    private enum CodingKeys: String, CodingKey {
        case id, title, overview
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
}
