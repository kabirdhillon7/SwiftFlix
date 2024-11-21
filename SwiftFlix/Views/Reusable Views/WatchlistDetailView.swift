//
//  WatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct WatchlistDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    
    @Bindable var watchlist: Watchlist
    @State var isNameEmptyAlertPresented: Bool = false
    @State var presentAddMoviesSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    watchlistDetails
                    ForEach(watchlist.movies) { movie in
                        HStack(spacing: 10) {
                            NavigationLink {
                                MovieDetailView(movie: movie)
                            } label: {
                                if let posterPath = movie.posterPath {
                                    CachedAsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                        image
                                            .resizable()
                                            .frame(width: 92.5, height: 138.75)
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 92.5)
                                    }
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(width: 92.5, height: 138.75)
                                        Image(systemName: "film")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color(UIColor.lightGray))
                                    }
                                }
                                
                                VStack(spacing: 5) {
                                    Text(movie.title)
                                        .ralewayFont(.title)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Text(movie.overview)
                                        .ralewayFont(.body)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .lineLimit(4)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteMovie)
                    
                    addMovieButton
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $presentAddMoviesSheet) {
                NavigationStack {
                    SearchToAddToWatchListView(watchlist: watchlist)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        EditButton()
                        Button {
                            deleteWatchlist()
                        } label: {
                            Label("Delete Watchlist", systemImage: "trash")
                                .ralewayFont(.body)
                        }
                        .foregroundColor(.red)
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .ralewayFont(.caption)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background {
                                Circle()
                                    .foregroundStyle(.black.opacity(0.2))
                            }
                    }
                }
            }
        }
    }
    
    var watchlistDetails: some View {
        VStack {
            if editMode?.wrappedValue == .active {
                TextField("Watchlist Name", text: $watchlist.title)
                    .submitLabel(.done)
                    .alert("Watchlist name cannot be empty", isPresented: $isNameEmptyAlertPresented) {
                        Button("OK", role: .cancel) { }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                TextField("Description", text: $watchlist.details, prompt: Text("Description"))
                    .submitLabel(.done)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            } else {
                Text(watchlist.title)
                    .ralewayFont(.largeTitle)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                if !watchlist.details.isEmpty {
                    Text(watchlist.details)
                        .ralewayFont(.caption)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 2)
                }
            }
        }
    }
    
    var addMovieButton: some View {
        Button {
            presentAddMoviesSheet = true
        } label: {
            Label("Add Movie", systemImage: "plus.app")
                .ralewayFont(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }
    
    private func deleteMovie(_ indexSet: IndexSet) {
        watchlist.movies.remove(atOffsets: indexSet)
        try? modelContext.save()
    }
    
    private func deleteWatchlist() {
        modelContext.delete(watchlist)
        try? modelContext.save()
        dismiss()
    }
}

//#Preview {
//    WatchListView()
//}
