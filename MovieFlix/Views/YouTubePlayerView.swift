//
//  YouTubePlayerView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 6/18/23.
//

import Foundation
import WebKit
import SwiftUI

struct YouTubePlayerView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youTubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            return
        }
        
        let request = URLRequest(url: youTubeURL)
        uiView.load(request)
    }
}
