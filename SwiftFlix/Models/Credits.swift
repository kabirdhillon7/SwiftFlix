//
//  Credits.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

struct Credits: Decodable, Equatable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable, Equatable, Identifiable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String

    private enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

struct Crew: Decodable, Equatable, Identifiable {
    let id: Int
    let name: String
    let profilePath: String?
    let job: String

    private enum CodingKeys: String, CodingKey {
        case id, name, job
        case profilePath = "profile_path"
    }
}

struct VideoResults: Decodable, Equatable {
    let results: [Video]
}

struct Video: Decodable, Equatable, Identifiable {
    let id: String
    let key: String
    let site: String
    let type: String
    let name: String
}
