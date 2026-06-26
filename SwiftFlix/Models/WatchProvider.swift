//
//  WatchProvider.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

struct WatchProviderResults: Decodable, Equatable {
    let results: [String: CountryResult]
}

struct CountryResult: Decodable, Equatable {
    let link: String
}
