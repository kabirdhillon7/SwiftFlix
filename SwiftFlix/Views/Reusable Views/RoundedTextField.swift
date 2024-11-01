//
//  CustomTextField.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/31/24.
//

import SwiftUI

struct RoundedTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .ralewayFont(.subheadline)
                .foregroundStyle(.gray)
            configuration
                .ralewayFont(.body, size: 16.5, weight: .medium)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            Color(UIColor.systemGray6)
        )
        .clipShape(Capsule(style: .continuous))
    }
}

#Preview {
    @Previewable @State var search: String = ""
    TextField("", text: $search, prompt: Text("Search"))
        .textFieldStyle(RoundedTextField())
        .padding()
}

