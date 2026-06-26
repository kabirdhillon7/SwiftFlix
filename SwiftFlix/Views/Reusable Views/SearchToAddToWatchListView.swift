//
//  SearchToAddToWatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftData
import SwiftUI

struct SearchToAddToWatchListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var watchlist: Watchlist
    @State private var viewModel = SearchToAddToWatchListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchQuery.isEmpty {
                    ContentUnavailableView(
                        "Search Movies",
                        systemImage: "magnifyingglass",
                        description: Text("Search for a movie to add it to this watchlist.")
                    )
                } else {
                    resultsContent
                }
            }
            .navigationTitle("Add to \(watchlist.title)")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchImmediately(modelContext: modelContext)
                }
            }
            .onChange(of: viewModel.searchQuery) {
                viewModel.searchDebounced(modelContext: modelContext)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private var resultsContent: some View {
        switch viewModel.phase {
        case .loading where viewModel.searchResults.isEmpty:
            ProgressView("Searching")
                .ralewayFont(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            ContentUnavailableView.search(text: viewModel.searchQuery)
        case .failed(let message):
            ContentUnavailableView(
                "Search Failed",
                systemImage: "wifi.exclamationmark",
                description: Text(message)
            )
        default:
            List(viewModel.searchResults) { movie in
                HStack(spacing: 12) {
                    MovieListRow(movie: movie)

                    Button {
                        toggle(movie)
                    } label: {
                        Image(systemName: watchlist.contains(movie) ? "checkmark.circle.fill" : "plus.circle")
                            .font(.title2)
                            .foregroundStyle(watchlist.contains(movie) ? .green : .accentColor)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
        }
    }

    private func toggle(_ movie: Movie) {
        watchlist.toggle(movie)
        try? modelContext.save()
    }
}
