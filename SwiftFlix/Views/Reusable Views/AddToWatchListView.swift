//
//  AddToWatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftUI
import SwiftData

struct AddToWatchListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    var movie: Movie
    
    @Query(sort: \Watchlist.title) var watchlists: [Watchlist]
    @State private var newWatchListName: String = ""
    @State private var presentNewWatchListAlert: Bool = false
    
    var body: some View {
        VStack {
            List {
                createWatchListButton
                ForEach(watchlists) { watchlist in
                    Button {
                        addMovieToWatchList(watchlist)
                    } label: {
                        Text(watchlist.title)
                            .foregroundStyle(.primary)
                            .ralewayFont(.body, size: 16, weight: .semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Add to a Watch List")
        .navigationBarTitleDisplayMode(.inline)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                        .ralewayFont(.body, size: 16, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(.primary)
                        .ralewayFont(.body, size: 16, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    var createWatchListButton: some View {
        Button {
            presentNewWatchListAlert.toggle()
        } label: {
            Label("Create New Watch List", systemImage: "plus")
                .ralewayFont(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func createNewWatchList() {
        let newWatchList = Watchlist(
            name: newWatchListName,
            details: "",
            movies: [movie]
        )
        modelContext.insert(newWatchList)
        try? modelContext.save()
        newWatchListName = ""
        
        dismiss()
    }
    
    private func addMovieToWatchList(_ watchList: Watchlist) {
        watchList.movies.append(movie)
        try? modelContext.save()
    }

}

#Preview {
    let sampleMovie = Movie(
        id: 502356,
        title: "The Super Mario Bros. Movie",
        overview: "While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are transported down a mysterious pipe and wander into a magical new world. But when the brothers are separated, Mario embarks on an epic quest to find Luigi.",
        posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
        backdropPath: "/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg",
        voteAverage: 7.7,
        isWatched: false,
        isBookmarked: false
    )
    NavigationStack {
        AddToWatchListView(movie: sampleMovie)
    }
}
