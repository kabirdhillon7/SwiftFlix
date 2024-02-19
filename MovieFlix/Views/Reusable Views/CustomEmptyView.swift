//
//  CustomEmptyView.swift
//  MovieFlix
//
//  Created by Kabir Dhillon on 2/18/24.
//

import SwiftUI

/// A  view that displays an empty state with a symbol, title, and subheading.
struct CustomEmptyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Properties
    @State var sfSymbolName: String
    @State var title: String
    @State var subheading: String
    
    // MARK: Body
    var body: some View {
            Image(systemName: sfSymbolName)
                .font(.system(size: 75))
                .foregroundColor(Color(UIColor.lightGray))
            Spacer()
                .frame(height: 5)
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text(subheading)
                .font(.subheadline)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? .white : .black)
    }
}

#Preview {
    CustomEmptyView(sfSymbolName: "film.stack.fill",
                    title: "No Queued Movies",
                    subheading: "When you add movies to your queue list, they'll appear here.")
}
