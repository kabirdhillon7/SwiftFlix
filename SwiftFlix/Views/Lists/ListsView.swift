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
    @State private var presentNewWatchListAlert: Bool = false
    @State private var newWatchListName: String = ""
    @State private var createNewWatchlistButtonTapped: Bool = false

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

                switch selectedListTab {
                case .saved:
                    if bookmarkedMovies.isEmpty {
                        ContentUnavailableView(
                            "No Saved Movies",
                            systemImage: "bookmark.slash",
                            description: Text("When you add movies to your saved list, they'll appear here.")
                        )
                    } else {
                        MovieGridView(movies: bookmarkedMovies)
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
                    }
                case .watchlists:
                    watchlistsContent
                }
            }
            .navigationTitle("Lists")
            .padding(.horizontal)
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
                .ralewayFont(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .liquidGlass(cornerRadius: 24)
        .padding(.bottom, 10)
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
                ForEach(watchlists) { watchlist in
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
