//
//  ListsView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftData
import SwiftUI

/// A view responsible for displaying movie lists
struct ListsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query(filter: #Predicate<Movie> { $0.isBookmarked == true }) private var bookmarkedMovies: [Movie]
    @Query(filter: #Predicate<Movie> { $0.isWatched == true }) private var watchedMovies: [Movie]

    @State private var selectedListTab = ListPickerItem.saved
    
    private enum ListPickerItem: String, CaseIterable, Identifiable {
        var id: Self { self }
        case saved, watched
    }

    var body: some View {
        NavigationStack {
            VStack {
                CustomPicker(selection: $selectedListTab, items: ListPickerItem.allCases) { item in
                    Text(item.rawValue.capitalized)
                        .ralewayFont(.body, size: 16, weight: .semibold)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
//                .frame(maxWidth: .infinity)
//                Picker("", selection: $selectedListTab) {
//                    ForEach(ListPickerItem.allCases) {
//                        Text($0.rawValue.capitalized)
//                            .ralewayFont(.body)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)

                switch selectedListTab {
                case .saved:
                    if bookmarkedMovies.isEmpty {
                        ContentUnavailableView(
                            "No Saved Movies",
                            systemImage: "bookmark",
                            description: Text("When you add movies to your saved list, they'll appear here.")
                        )
                    } else {
                        MovieGridView(movies: bookmarkedMovies)
                            .padding(.horizontal)
                    }
                case .watched:
                    if watchedMovies.isEmpty {
                        ContentUnavailableView(
                            "No Watched Movies",
                            systemImage: "tv.slash",
                            description: Text("When you add movies you've watched, they'll appear here.")
                        )
                    } else {
                        MovieGridView(movies: watchedMovies)
                            .padding(.horizontal)
                    }
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Lists")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Movie.self, configurations: config)
        return ListsView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
    }
}
