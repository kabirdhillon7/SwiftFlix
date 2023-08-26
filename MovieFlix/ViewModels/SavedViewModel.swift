//
//  SavedViewModel.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import Foundation
import SwiftUI

final class SavedViewModel: ObservableObject {
    @Published var savedMovie: SavedMovie = SavedMovie()
}
