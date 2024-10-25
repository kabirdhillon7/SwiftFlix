//
//  WatchListView.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 2/19/24.
//

import SwiftUI

struct WatchlistView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var movieLists: MovieLists
    
    @Binding var watchlist: Watchlist
    @State var watchListName: String = ""
    @State var isNameEmptyAlertPresented: Bool = false
    
    @State var presentAddMoviesSheet: Bool = false
    
    var body: some View {
        List {
            if editMode?.wrappedValue == .active {
                TextField("", text: $watchListName)
                    .submitLabel(.done)
                    .onSubmit {
                        if watchListName.isEmpty {
                            isNameEmptyAlertPresented = true
                        } else {
                            if let index = movieLists.watchLists.firstIndex(where: { $0.id == watchlist.id }) {
                                DispatchQueue.main.async {
                                    movieLists.watchLists[index].name = watchListName
                                    movieLists.saveWatchLists()
                                }
                            }
                        }
                    }
                    .alert("Watchlist name cannot be empty", isPresented: $isNameEmptyAlertPresented) {
                        Button("OK", role: .cancel) { }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }

            var watchListMoviesListArray = Array(watchlist.moviesList)
            ForEach(watchListMoviesListArray, id: \.self) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    HStack(spacing: 10) {
                        if let posterPath = movie.posterPath {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 61, height: 91.5)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(10)
                                case .failure(_):
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(width: 61, height: 91.5)
                                        Image(systemName: "film")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color(UIColor.lightGray))
                                    }
                                default:
                                    ProgressView()
                                }
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(width: 61, height: 91.5)
                                Image(systemName: "film")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(UIColor.lightGray))
                            }
                        }
                        
                        Text(movie.title)
                            .font(.system(size: 20))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .onDelete(perform: { indexSet in
                watchListMoviesListArray.remove(atOffsets: indexSet)
                
                if let index = movieLists.watchLists.firstIndex(where: { $0.id == watchlist.id }) {
                    movieLists.watchLists[index].moviesList = Set(watchListMoviesListArray)
                    movieLists.saveWatchLists()
                }
            })
            .onAppear {
                watchListMoviesListArray = Array(watchlist.moviesList)
            }
            
            Button {
                presentAddMoviesSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.app")
                        .resizable()
                        .frame(width: 61, height: 61)
                    Text("Add Movie")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20))
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            watchListName = watchlist.name
        }
        .listStyle(.plain)
        .navigationTitle(watchListName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $presentAddMoviesSheet, content: {
            NavigationStack {
                SearchToAddToWatchListView(watchlist: $watchlist)
            }
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        let index = movieLists.watchLists.firstIndex { item in
                            item.id == self.watchlist.id
                        }
                        if let index = index {
                            movieLists.watchLists.remove(at: index)
                            movieLists.saveWatchLists()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Watchlist")
                        }
                        .foregroundColor(.red)
                    }
                    
                    EditButton()
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

//#Preview {
//    WatchListView()
//}
