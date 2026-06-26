//
//  WatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftData
import SwiftUI

struct WatchlistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode

    @Bindable var watchlist: Watchlist
    @State private var isNameEmptyAlertPresented = false
    @State private var presentAddMoviesSheet = false
    @State private var addFeedback = false
    @State private var deleteFeedback = false

    var body: some View {
        List {
            watchlistDetails
                .listRowSeparator(.hidden)

            if watchlist.movies.isEmpty {
                ContentUnavailableView(
                    "No Movies",
                    systemImage: "film.stack",
                    description: Text("Add movies to build this watchlist.")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(watchlist.movies) { movie in
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieListRow(movie: movie)
                    }
                }
                .onDelete(perform: deleteMovie)
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            addMovieButton
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.clear)
        }
        .navigationTitle(watchlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $presentAddMoviesSheet) {
            SearchToAddToWatchListView(watchlist: watchlist)
        }
        .sensoryFeedback(.selection, trigger: addFeedback)
        .sensoryFeedback(.warning, trigger: deleteFeedback)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .padding(10)
                        .liquidGlassCapsule()
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    EditButton()
                    Button(role: .destructive) {
                        deleteWatchlist()
                    } label: {
                        Label("Delete Watchlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .padding(10)
                        .liquidGlassCapsule()
                }
            }
        }
    }

    private var watchlistDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            if editMode?.wrappedValue == .active {
                TextField("Watchlist Name", text: $watchlist.title)
                    .submitLabel(.done)
                    .alert("Watchlist name cannot be empty", isPresented: $isNameEmptyAlertPresented) {
                        Button("OK", role: .cancel) { }
                    }
                TextField("Description", text: $watchlist.details, prompt: Text("Description"))
                    .submitLabel(.done)
            } else {
                Text(watchlist.title)
                    .ralewayFont(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !watchlist.details.isEmpty {
                    Text(watchlist.details)
                        .ralewayFont(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical)
    }

    private var addMovieButton: some View {
        Button {
            addFeedback.toggle()
            presentAddMoviesSheet = true
        } label: {
            Label("Add Movie", systemImage: "plus")
                .ralewayFont(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .liquidGlass(cornerRadius: 24)
    }

    private func deleteMovie(_ indexSet: IndexSet) {
        watchlist.movies.remove(atOffsets: indexSet)
        try? modelContext.save()
        deleteFeedback.toggle()
    }

    private func deleteWatchlist() {
        modelContext.delete(watchlist)
        try? modelContext.save()
        deleteFeedback.toggle()
        dismiss()
    }
}
