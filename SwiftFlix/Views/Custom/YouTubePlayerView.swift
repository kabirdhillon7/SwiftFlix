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
    
    /// Creates the initial WKWebView
    ///
    /// - Parameters: context: The view context.
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    /// Updates the WKWebView when the video ID changes
    ///
    /// - Parameters:
    ///     - uiView: The WKWebView to update.
    ///     - context: The view context.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youTubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            return
        }
        
        let request = URLRequest(url: youTubeURL)
        uiView.load(request)
    }
}
