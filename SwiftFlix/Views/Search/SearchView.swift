//
//  SearchView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 6/24/23.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchQuery.isEmpty {
                    ContentUnavailableView(
                        "Search Movies",
                        systemImage: "magnifyingglass",
                        description: Text("Find a movie, then save it, mark it watched, or add it to a watchlist.")
                    )
                } else {
                    resultsContent
                }
            }
            .navigationTitle("Search")
            .searchable(text: $viewModel.searchQuery, placement: .automatic, prompt: "Search movies")
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchImmediately(modelContext: modelContext)
                }
            }
            .onChange(of: viewModel.searchQuery) {
                viewModel.searchDebounced(modelContext: modelContext)
            }
            .modifier(SearchToolbarCompatibility())
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
                NavigationLink {
                    MovieDetailView(movie: movie)
                } label: {
                    MovieListRow(movie: movie)
                }
            }
            .listStyle(.plain)
        }
    }
}

private struct SearchToolbarCompatibility: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.searchToolbarBehavior(.automatic)
        } else {
            content
        }
    }
}

#Preview {
    SearchView()
}
