//
//  CustomPicker.swift
//  SwiftFlix
//
//  Created by Kabir Dhillon on 10/31/24.
//

import SwiftUI

struct CustomPicker<SelectionValue: Hashable, Content: View>: View {
    @Binding var selection: SelectionValue
    let items: [SelectionValue]
    let content: (SelectionValue) -> Content
    
    @Namespace private var animationNamespace
    
    @ViewBuilder
    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                let isSelected = selection == item
                Button {
                    withAnimation {
                        selection = item
                    }
                } label: {
                    content(item)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .foregroundColor(isSelected ? .white : .gray)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.accentColor)
                                    .matchedGeometryEffect(id: "highlighted", in: animationNamespace)
                            }
                        }
                }
                .padding(5)
            }
        }
        .background(content: {
            Capsule()
                .foregroundStyle(.bar)
        })
    }
}

#Preview {
    @Previewable @State var selected = "One"
    @Previewable @State var options: [String] = ["One", "Two", "Three"]
    CustomPicker(selection: $selected, items: options) { option in
        Text(option)
            .ralewayFont(.body)
    }
    .padding()
}
