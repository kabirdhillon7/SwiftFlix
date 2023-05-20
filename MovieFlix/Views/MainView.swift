//
//  MainView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 5/18/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MovieView()
                .tabItem {
                    Label("Now Playing", systemImage: "film")
                }
            // Search, Saved
            
//            OrderView()
//                .tabItem {
//                    Label("Order", systemImage: "square.and.pencil")
//                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
