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
    /*
     {
     "adult": false,
     "gender": 2,
     "id": 819,
     "known_for_department": "Acting",
     "name": "Edward Norton",
     "original_name": "Edward Norton",
     "popularity": 26.99,
     "profile_path": "/8nytsqL59SFJTVYVrN72k6qkGgJ.jpg",
     "cast_id": 4,
     "character": "The Narrator",
     "credit_id": "52fe4250c3a36847f80149f3",
     "order": 0
     },
     */
    let id: Int
    let name: String
    let profilePath: String?
    let character: String
}

struct Crew: Codable {
    /*
     "adult": false,
     "gender": 2,
     "id": 376,
     "known_for_department": "Production",
     "name": "Arnon Milchan",
     "original_name": "Arnon Milchan",
     "popularity": 2.931,
     "profile_path": "/b2hBExX4NnczNAnLuTBF4kmNhZm.jpg",
     "credit_id": "55731b8192514111610027d7",
     "department": "Production",
     "job": "Executive Producer"
     */
    let id: Int
    let name: String
    let profilePath: String?
    let job: String
}
