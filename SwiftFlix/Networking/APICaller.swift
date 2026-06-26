//
//  APICaller.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation

enum MovieCategory: String, CaseIterable, Identifiable {
    case nowPlaying = "now_playing"
    case popular
    case upcoming

    var id: String { rawValue }

    var title: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        }
    }
}

enum TMDBError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case noTrailer

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your TMDB API key to the TMDB_API_KEY build setting."
        case .invalidURL:
            return "SwiftFlix could not build a valid TMDB request."
        case .invalidResponse:
            return "TMDB returned an unexpected response."
        case .httpStatus(let statusCode):
            return "TMDB returned HTTP \(statusCode)."
        case .noTrailer:
            return "No trailer is available for this movie."
        }
    }
}

struct TMDBConfiguration {
    var apiKey: String
    var baseURL: URL
    var imageBaseURL: URL

    init(
        apiKey: String = TMDBConfiguration.apiKeyFromBundle(),
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        imageBaseURL: URL = URL(string: "https://image.tmdb.org/t/p")!
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.imageBaseURL = imageBaseURL
    }

    private static func apiKeyFromBundle() -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDBAPIKey") as? String else {
            return ""
        }
        return value.hasPrefix("$(") ? "" : value
    }
}

protocol HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionHTTPClient: HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }
        return (data, httpResponse)
    }
}

protocol TMDBClientProtocol {
    func movies(in category: MovieCategory) async throws -> [MovieDTO]
    func searchMovies(query: String) async throws -> [MovieDTO]
    func movie(id: Int) async throws -> MovieDTO
    func trailerKey(movieID: Int) async throws -> String?
    func recommendations(movieID: Int) async throws -> [MovieDTO]
    func credits(movieID: Int) async throws -> Credits
    func watchProviderLink(movieID: Int, countryCode: String) async throws -> URL?
}

struct TMDBClient: TMDBClientProtocol {
    private let configuration: TMDBConfiguration
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder

    init(
        configuration: TMDBConfiguration = TMDBConfiguration(),
        httpClient: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.decoder = decoder
    }

    func movies(in category: MovieCategory) async throws -> [MovieDTO] {
        let response: MovieResults = try await request(.movieList(category))
        return response.results
    }

    func searchMovies(query: String) async throws -> [MovieDTO] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        let response: MovieResults = try await request(.search(query))
        return response.results
    }

    func movie(id: Int) async throws -> MovieDTO {
        try await request(.movie(id))
    }

    func trailerKey(movieID: Int) async throws -> String? {
        let response: VideoResults = try await request(.videos(movieID))
        return response.results.first { video in
            video.site == "YouTube" && video.type == "Trailer"
        }?.key
    }

    func recommendations(movieID: Int) async throws -> [MovieDTO] {
        let response: MovieResults = try await request(.recommendations(movieID))
        return response.results
    }

    func credits(movieID: Int) async throws -> Credits {
        try await request(.credits(movieID))
    }

    func watchProviderLink(movieID: Int, countryCode: String = "US") async throws -> URL? {
        let response: WatchProviderResults = try await request(.watchProviders(movieID))
        guard let link = response.results[countryCode]?.link else {
            return nil
        }
        return URL(string: link)
    }

    private func request<T: Decodable>(_ endpoint: TMDBEndpoint) async throws -> T {
        guard !configuration.apiKey.isEmpty else {
            throw TMDBError.missingAPIKey
        }

        let url = try endpoint.url(configuration: configuration)
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await httpClient.data(for: request)
        guard 200..<300 ~= response.statusCode else {
            throw TMDBError.httpStatus(response.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}

private enum TMDBEndpoint {
    case movieList(MovieCategory)
    case search(String)
    case movie(Int)
    case videos(Int)
    case recommendations(Int)
    case credits(Int)
    case watchProviders(Int)

    func url(configuration: TMDBConfiguration) throws -> URL {
        var components = URLComponents()
        components.scheme = configuration.baseURL.scheme
        components.host = configuration.baseURL.host
        components.path = configuration.baseURL.path + path
        components.queryItems = queryItems(apiKey: configuration.apiKey)

        guard let url = components.url else {
            throw TMDBError.invalidURL
        }
        return url
    }

    private var path: String {
        switch self {
        case .movieList(let category):
            return "/movie/\(category.rawValue)"
        case .search:
            return "/search/movie"
        case .movie(let id):
            return "/movie/\(id)"
        case .videos(let id):
            return "/movie/\(id)/videos"
        case .recommendations(let id):
            return "/movie/\(id)/recommendations"
        case .credits(let id):
            return "/movie/\(id)/credits"
        case .watchProviders(let id):
            return "/movie/\(id)/watch/providers"
        }
    }

    private func queryItems(apiKey: String) -> [URLQueryItem] {
        var items = [URLQueryItem(name: "api_key", value: apiKey)]

        if case .search(let query) = self {
            items.append(URLQueryItem(name: "query", value: query))
        }

        return items
    }
}
