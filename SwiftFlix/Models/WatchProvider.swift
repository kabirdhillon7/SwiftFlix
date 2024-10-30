//
//  WatchProvider.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

/// Watch Provider Results from The Movie Database
struct WatchProviderResults: Codable {
    let results: [String:CountryResult]
}

/// Watch Provider
struct WatchProvider: Codable {
    let results: WatchProviderResults
}

/// Country Result
struct CountryResult: Codable {
    let link: String
}
