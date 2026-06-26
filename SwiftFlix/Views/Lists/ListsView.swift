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
    @Query(sort: \Watchlist.title) var watchlists: [Watchlist]

    @State private var selectedListTab = ListPickerItem.saved
    @State private var movieSortOption = MovieSortOption.title
    @State private var watchlistSortOption = WatchlistSortOption.title
    @State private var presentNewWatchListAlert: Bool = false
    @State private var newWatchListName: String = ""
    @State private var createNewWatchlistButtonTapped: Bool = false
    @State private var createFeedback = false
    @State private var deleteFeedback = false

    private enum ListPickerItem: String, CaseIterable, Identifiable {
        var id: Self { self }
        case saved, watched, watchlists

        var title: String {
            switch self {
            case .saved:
                return "Saved"
            case .watched:
                return "Watched"
            case .watchlists:
                return "Watchlists"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("List type", selection: $selectedListTab) {
                    ForEach(ListPickerItem.allCases) { item in
                        Text(item.title)
                            .tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.accentColor)
                .padding(6)
                .liquidGlass(cornerRadius: 20)
                .padding(.top, 6)

                sortControls

                switch selectedListTab {
                case .saved:
                    if bookmarkedMovies.isEmpty {
                        emptyMoviesState(
                            title: "No Saved Movies",
                            systemImage: "bookmark.slash",
                            description: "Find a movie, then tap Saved to keep it here."
                        )
                    } else {
                        MovieGridView(movies: bookmarkedMovies.sorted(by: movieSortOption))
                    }
                case .watched:
                    if watchedMovies.isEmpty {
                        emptyMoviesState(
                            title: "No Watched Movies",
                            systemImage: "tv.slash",
                            description: "Search for movies you've seen, then mark them watched."
                        )
                    } else {
                        MovieGridView(movies: watchedMovies.sorted(by: movieSortOption))
                    }
                case .watchlists:
                    watchlistsContent
                }
            }
            .navigationTitle("Lists")
            .padding(.horizontal)
            .sensoryFeedback(.success, trigger: createFeedback)
            .sensoryFeedback(.warning, trigger: deleteFeedback)
            .alert("New Watch List", isPresented: $presentNewWatchListAlert, actions: {
                TextField("", text: $newWatchListName, prompt: Text("Watch List Title"))
                Button("Cancel", role: .cancel) {
                    newWatchListName = ""
                }
                Button("Add", role: .none) {
                    createNewWatchList()
                }
                .disabled(newWatchListName.isEmpty)
            })
        }
    }

    @ViewBuilder
    private var sortControls: some View {
        HStack {
            Text("Sort")
                .ralewayFont(.caption, weight: .semibold)
                .foregroundStyle(.secondary)

            Spacer()

            if selectedListTab == .watchlists {
                Picker("Sort Watchlists", selection: $watchlistSortOption) {
                    ForEach(WatchlistSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Picker("Sort Movies", selection: $movieSortOption) {
                    ForEach(MovieSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(.horizontal, 4)
    }

    private func emptyMoviesState(
        title: String,
        systemImage: String,
        description: String
    ) -> some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text(description)
            )

            NavigationLink {
                SearchView()
            } label: {
                Label("Find Movies", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(TintedGlassButtonStyle(tint: .accentColor))
            .padding(.horizontal, 44)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var createWatchListButton: some View {
        Button {
            withAnimation {
                createNewWatchlistButtonTapped.toggle()
            }
            presentNewWatchListAlert.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                createNewWatchlistButtonTapped = false
            }
        } label: {
            Label("Create New Watch List", systemImage: "plus")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(TintedGlassButtonStyle(tint: .accentColor))
        .padding(.bottom, 10)
        .padding(.horizontal, 44)
        .scaleEffect(createNewWatchlistButtonTapped ? 1.04 : 1)
        .animation(.easeInOut, value: createNewWatchlistButtonTapped)
    }

    @ViewBuilder
    private var watchlistsContent: some View {
        if watchlists.isEmpty {
            ContentUnavailableView(
                "No Watchlists",
                systemImage: "square.3.layers.3d.slash",
                description: Text("When you add watchlists, they'll appear here.")
            )
            .safeAreaInset(edge: .bottom) {
                createWatchListButton
            }
        } else {
            List {
                ForEach(watchlists.sorted(by: watchlistSortOption)) { watchlist in
                    NavigationLink {
                        WatchlistDetailView(watchlist: watchlist)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(watchlist.title)
                                .ralewayFont(.headline)
                            Text("\(watchlist.movies.count) movies")
                                .ralewayFont(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete(perform: deleteWatchlist)
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                createWatchListButton
            }
        }
    }

    private func deleteWatchlist(_ indexSet: IndexSet) {
        for i in indexSet {
            let watchlist = watchlists[i]
            modelContext.delete(watchlist)
            try? modelContext.save()
            deleteFeedback.toggle()
        }
    }

    private func createNewWatchList() {
        let newWatchList = Watchlist(
            name: newWatchListName,
            details: "",
            movies: []
        )
        modelContext.insert(newWatchList)
        try? modelContext.save()
        newWatchListName = ""
        createFeedback.toggle()
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
