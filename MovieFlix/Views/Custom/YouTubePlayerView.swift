//
//  YouTubePlayerView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 6/18/23.
//

import Foundation
import WebKit
import SwiftUI

/// A  view representing a YouTube video player using WKWebView
struct YouTubePlayerView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let videoID: String
    
    // MARK: Creates the initial WKWebView
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    // MARK: Updates the WKWebView when the video ID changes
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youTubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            return
        }
        
        let request = URLRequest(url: youTubeURL)
        uiView.load(request)
    }
}
