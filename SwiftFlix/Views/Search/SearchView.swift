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
            SearchResultsSkeletonView()
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

private struct SearchResultsSkeletonView: View {
    var body: some View {
        List(0..<6, id: \.self) { _ in
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 78, height: 117)

                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .frame(width: 180, height: 18)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .frame(width: 220, height: 12)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .frame(width: 70, height: 12)
                }
            }
            .padding(.vertical, 6)
            .redacted(reason: .placeholder)
        }
        .listStyle(.plain)
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
