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
                Picker("", selection: $selectedListTab) {
                    ForEach(ListPickerItem.allCases) {
                        Text($0.rawValue.capitalized)
                            .ralewayFont(.body)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

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
//                if selectedListTab == 0 {
//                    if bookmarkedMovies.isEmpty {
//                        ContentUnavailableView(
//                            "No Saved Movies",
//                            systemImage: "bookmark",
//                            description: Text("When you add movies to your saved list, they'll appear here.")
//                        )
//                    } else {
//                        
//                    }
//                } else if selectedListTab == 1 {
//                    ContentUnavailableView(
//                        "No Watched Movies",
//                        systemImage: "tv.slash",
//                        description: Text("When you add movies you've watched, they'll appear here.")
//                    )
//                } else {
//                    List {
//                        Button {
//                            presentCreateNewWatchlist = true
//                        } label: {
//                            HStack(alignment: .firstTextBaseline, spacing: 10) {
//                                Image(systemName: "plus.app")
//                                    .font(.system(size: 20))
//                                Text("New Watchlist...")
//                                    .frame(maxWidth: .infinity,alignment: .leading)
//                                    .font(.system(size: 20))
//                            }
//                            .foregroundColor(.accentColor)
//                        }
//                        
//                    }
//                    .listStyle(.plain)
//                }
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
