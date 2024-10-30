//
//  AddToWatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftUI

struct AddToWatchListView: View {
    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var movieLists: MovieLists
    
    var movie: Movie
    @State var presentNewWatchlist: Bool = false
    @State var newWatchListTitle: String = ""
    
    @State var movieInWatchlist: Bool = false
    @State var movieAddedToWatchlist: Bool = false
    @State var movieAdded: Bool = false
    
    var body: some View {
        List {
            EmptyView()
//            Button {
//                presentNewWatchlist = true
//            } label: {
//                HStack(alignment: .firstTextBaseline, spacing: 10) {
//                    Image(systemName: "plus.app")
//                        .font(.system(size: 20))
//                    Text("New Watchlist...")
//                        .font(.system(size: 20))
//                }
//                .foregroundColor(.accentColor)
//            }
//            
//            ForEach(movieLists.watchLists, id: \.id) { watchList in
//                Button {
//                    if watchList.moviesList.contains(movie) {
//                        movieInWatchlist = true
//                    } else {
//                        watchList.add(movie)
//                        movieLists.saveWatchLists()
//                        movieAdded = true
//                    }
//                } label: {
//                    VStack(spacing: 5) {
//                        Text(watchList.name)
//                            .font(.system(size: 20))
//                            .bold()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .foregroundColor(.primary)
//                        
//                        if watchList.moviesList.contains(movie) {
//                            Text("Already Added")
//                                .font(.body)
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .lineLimit(1)
//                        }
//                    }
//                }
//            }
        }
        .listStyle(.plain)
        .alert("New Watchlist", isPresented: $presentNewWatchlist) {
            TextField("",
                      text: $newWatchListTitle,
                      prompt: Text("Watchlist Title"))
            Button("Cancel", role: .cancel) { }
            Button("Add") {
//                DispatchQueue.main.async {
//                    movieLists.watchLists.append(Watchlist(name: newWatchListTitle))
//                    if let newestWatchList = movieLists.watchLists.last {
//                        newestWatchList.add(movie)
//                    }
//                    movieLists.saveWatchLists()
//                }
            }
        }
        .alert("This movie is already in your watchlist", isPresented: $movieInWatchlist) {
            Button("OK", role: .cancel) { }
        }
        .alert("Movie added to watchlist", isPresented: $movieAddedToWatchlist) {
            Button("OK", role: .cancel) { }
        }
        .alert("Movie added to watchlist", isPresented: $movieAdded) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle("Add to a Watchlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

//#Preview {
//    AddToWatchListView()
//        .environmentObject(MovieLists())
//}
