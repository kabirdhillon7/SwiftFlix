//
//  APICaller.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import Foundation
import Combine

/// Enum that stores API information
enum APIInformation: String {
    case key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
}

/// Protocol for DataServicing
protocol DataServicing {
    func getNowPlayingMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error>
    func getMovieTrailer(movieId: Int) -> AnyPublisher<String, Error>
    func getSearchMovieResults(searchQuery: String) -> AnyPublisher<[Movie], Error>
    func getMovieRecommendations(movieID: Int) -> AnyPublisher<[Movie], Error>
}

/// Class responsible for making API calls
class APICaller: DataServicing {
    
    let apiKey = APIInformation.key
    
    /// Fetches a list of movies recently playing in theaters
    /// - Parameters:
    ///    - url: The URL to the API.
    /// - Returns:
    ///     -  An `AnyPublisher` containing an array of `Movie` objects and a possible `Error`.
    func getNowPlayingMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error> {
        guard let requestUrl = URL(string: url.absoluteString + apiKey.rawValue) else {
            return Fail(error: NSError(domain: "Invalid url", code: 0)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .map({ $0.results })
            .eraseToAnyPublisher()
    }
    
    /// Fetches a list of movies ordered by popularity.
    /// - Parameters:
    ///    - url: The URL to the API.
    /// - Returns:
    ///     -  An `AnyPublisher` containing an array of `Movie` objects and a possible `Error`.
    func getPopularMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error> {
        guard let requestUrl = URL(string: url.absoluteString + apiKey.rawValue) else {
            return Fail(error: NSError(domain: "Invalid url", code: 0)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .map({ $0.results })
            .eraseToAnyPublisher()
    }
    
    /// Fetches a list of movies that are being released soon.
    /// - Parameters:
    ///    - url: The URL to the API.
    /// - Returns:
    ///     -  An `AnyPublisher` containing an array of `Movie` objects and a possible `Error`.
    func getUpcomingMovies(toUrl url: URL) -> AnyPublisher<[Movie], Error> {
        guard let requestUrl = URL(string: url.absoluteString + apiKey.rawValue) else {
            return Fail(error: NSError(domain: "Invalid url", code: 0)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .map({ $0.results })
            .eraseToAnyPublisher()
    }
    
    /// Fetches movie trailer from The Movie Database API
    ///
    /// - Parameters:
    ///    - movieId: The id of the specfic movie to fetch the trailer for
    /// - Returns:
    ///    -  An `AnyPublisher` of a `String` representing the key for the trailer, and an `Error`
    func getMovieTrailer(movieId: Int) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey.rawValue)") else {
            return Fail(error: NSError(domain: "Invalid trailer URL", code: 0)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .tryMap { try JSONSerialization.jsonObject(with: $0) }
            .compactMap { $0 as? [String: Any] }
            .compactMap { $0["results"] as? [[String: Any]] }
            .compactMap { $0.first(where: { ($0["type"] as? String) == "Trailer" }) }
            .map { ($0?["key"] as? String)! }
            .eraseToAnyPublisher()
    }
    
    /// Fetches movie search results from The Movie Database API
    ///
    /// - Parameters:
    ///     - searchQuery: The search input from the user
    /// - Returns:
    ///     -  An `AnyPublisher` containing an array of `Movie` objects and a possible `Error`.
    func getSearchMovieResults(searchQuery: String) -> AnyPublisher<[Movie], Error> {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey.rawValue)&query=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            return Fail(error: NSError(domain: "Invalid search URL", code: 0)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .map({ $0.results })
            .eraseToAnyPublisher()
    }
    
    
    /// Fetches movie recommendations results for a specific movie from The Movie Database API
    ///
    /// - Parameters:
    ///     - movieID: The id of the specfic movie to fetch the trailer for
    /// - Returns:
    ///     -  An `AnyPublisher` containing an array of `Movie` objects and a possible `Error`.
    func getMovieRecommendations(movieID: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/recommendations?api_key=\(apiKey.rawValue)") else {
            return Fail(error: NSError(domain: "Invalid movie recommendations", code: 0)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .map({ $0.results })
            .eraseToAnyPublisher()
    }
    
    /// Fetches movie details for a specific movie ID from The Movie Database API
    ///
    /// - Parameters:
    ///     - movieID: The id of the specfic movie to fetch the trailer for
    /// - Returns:
    ///     -  An `AnyPublisher` containing a `Movie` object and a possible `Error`.
    func getMovie(movieID: Int) -> AnyPublisher<Movie, Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey.rawValue)") else {
            return Fail(error: NSError(domain: "Unable to get movie details from movie id", code: 0)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: Movie.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getUSLink(movieID: Int) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/watch/providers?api_key=\(apiKey.rawValue)") else {
            return Fail(error: NSError(domain: "Unable to get movie providers link from movie id", code: 0)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: WatchProviderResults.self, decoder: JSONDecoder())
            .map { response in
                let result = response.results["US"]
                return result?.link ?? ""
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMovieCredits(movieID: Int) -> AnyPublisher<Credits, Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/credits?api_key=\(apiKey.rawValue)") else {
            return Fail(error: NSError(domain: "Unable to get movie providers link from movie id", code: 0)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: Credits.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
