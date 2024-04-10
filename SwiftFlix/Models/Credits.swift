//
//  Credits.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

import Foundation

struct Credits: Codable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Codable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String
}

struct Crew: Codable {
    let id: Int
    let name: String
    let profilePath: String?
    let job: String
}
