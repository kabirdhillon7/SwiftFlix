//
//  Credits.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 3/13/24.
//

import Foundation
import SwiftData

@Model
final class Credits: Decodable {
    let cast: [Cast]
    let crew: [Crew]
    
    private enum CodingKeys: String, CodingKey {
        case cast, crew
    }
    
    init(cast: [Cast], crew: [Crew]) {
        self.cast = cast
        self.crew = crew
    }
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        cast = try container.decode([Cast].self, forKey: .cast)
        crew = try container.decode([Crew].self, forKey: .crew)
    }
}

@Model
final class Cast: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
    
    init(id: Int, name: String, profilePath: String?, character: String) {
        self.id = id
        self.name = name
        self.profilePath = profilePath
        self.character = character
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
        character = try container.decode(String.self, forKey: .character)
    }
}

@Model
final class Crew: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let job: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, job
        case profilePath = "profile_path"
    }
    
    init(id: Int, name: String, profilePath: String?, job: String) {
        self.id = id
        self.name = name
        self.profilePath = profilePath
        self.job = job
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
        job = try container.decode(String.self, forKey: .job)
    }
}
