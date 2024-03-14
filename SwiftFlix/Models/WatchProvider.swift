//
//  WatchProvider.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

import Foundation

struct WatchProviderResults: Codable {
    var results: [String:CountryResult]
}

struct WatchProvider: Codable {
    var results: WatchProviderResults
}

struct CountryResult: Codable {
    var link: String
}
