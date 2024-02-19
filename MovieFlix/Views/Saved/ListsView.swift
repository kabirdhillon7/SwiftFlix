//
//  SavedView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 8/25/23.
//

import SwiftUI

/// A view responsible for displaying movie lists
struct ListsView: View {
    @EnvironmentObject var savedMoviesViewModel: SavedViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedListTab: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedListTab) {
                    Text("Queued")
                        .tag(0)
                    Text("Watched")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedListTab == 0 {
                    if savedMoviesViewModel.queuedMovie.movies.isEmpty {
                        Spacer()
                        Group {
                            Image(systemName: "film.stack.fill")
                                .font(.system(size: 75))
                                .foregroundColor(Color(UIColor.lightGray))
                            Spacer()
                                .frame(height: 5)
                            Text("No Queued Movies")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("When you add movies to your queue list, they'll appear here.")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .multilineTextAlignment(.center)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(Array(savedMoviesViewModel.queuedMovie.movies), id: \.self) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    HStack {
                                        if let posterPath = movie.poster_path {
                                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w185" + posterPath)) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 92.5, height: 138.75)
                                                    .aspectRatio(contentMode: .fill)
                                                    .cornerRadius(15)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Image(systemName: "photo")
                                        }
                                        Spacer()
                                            .frame(width: 10)
                                        Text(movie.title)
                                            .font(.system(size: 20))
                                            .bold()
                                            .frame(maxWidth: .infinity,alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .navigationTitle("Saved")
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
            .environmentObject(SavedViewModel())
    }
}
