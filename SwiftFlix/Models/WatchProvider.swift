//
//  WatchProvider.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

import Foundation

struct WatchProviderResults: Codable {
    let results: [String:CountryResult]
}

struct WatchProvider: Codable {
    let results: WatchProviderResults
}

struct CountryResult: Codable {
    let link: String
}
