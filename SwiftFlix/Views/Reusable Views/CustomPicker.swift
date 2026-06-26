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
        .liquidGlass(cornerRadius: 28)
    }
}

extension View {
    @ViewBuilder
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    @ViewBuilder
    func liquidGlassCapsule() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: Capsule())
        } else {
            background(.ultraThinMaterial, in: Capsule())
        }
    }

    @ViewBuilder
    func liquidGlassCircle() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: Circle())
        } else {
            background(.ultraThinMaterial, in: Circle())
        }
    }

    @ViewBuilder
    func scrollAwareTabBar() -> some View {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

    @ViewBuilder
    func artworkBackgroundExtension() -> some View {
        if #available(iOS 26.0, *) {
            backgroundExtensionEffect()
        } else {
            self
        }
    }

    func toastOverlay<Toast: View>(
        isPresented: Bool,
        @ViewBuilder content: () -> Toast
    ) -> some View {
        modifier(ToastOverlayModifier(isPresented: isPresented, toast: content()))
    }

    func liquidGlassToast(highContrast: Bool = false) -> some View {
        modifier(LiquidGlassToastModifier(highContrast: highContrast))
    }
}

private struct ToastOverlayModifier<Toast: View>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isPresented: Bool
    let toast: Toast

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    toast
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                        .transition(toastTransition)
                        .zIndex(1)
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86), value: isPresented)
    }

    private var toastTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .opacity.combined(with: .move(edge: .bottom))
    }
}

private struct LiquidGlassToastModifier: ViewModifier {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let highContrast: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        let useHighContrast = highContrast || colorSchemeContrast == .increased
        let shape = Capsule(style: .continuous)

        if #available(iOS 26.0, *) {
            content
                .background {
                    shape
                        .fill(.ultraThinMaterial)
                        .glassEffect(.regular, in: shape)
                }
                .overlay {
                    shape
                        .strokeBorder(.primary.opacity(useHighContrast ? 0.45 : 0.2), lineWidth: useHighContrast ? 1.5 : 1)
                }
                .shadow(color: .black.opacity(useHighContrast ? 0.18 : 0.22), radius: 18, y: 10)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape
                        .strokeBorder(.primary.opacity(useHighContrast ? 0.5 : 0.22), lineWidth: useHighContrast ? 1.5 : 1)
                }
                .shadow(color: .black.opacity(useHighContrast ? 0.16 : 0.2), radius: 18, y: 10)
        }
    }
}

struct SwiftFlixToast: View {
    let message: String
    let systemImage: String
    var tint: Color = .green

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(.primary.opacity(0.08), in: Circle())

            Text(message)
                .ralewayFont(.body, size: 15, weight: .semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlassToast()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

struct TintedGlassButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        let useHighContrast = colorSchemeContrast == .increased
        let shape = Capsule(style: .continuous)

        configuration.label
            .ralewayFont(.body, size: 16, weight: .semibold)
            .foregroundStyle(tint)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background {
                shape
                    .fill(tint.opacity(useHighContrast ? 0.22 : 0.14))
            }
            .overlay {
                shape
                    .strokeBorder(tint.opacity(useHighContrast ? 0.8 : 0.42), lineWidth: useHighContrast ? 1.5 : 1)
            }
            .liquidGlassCapsule()
            .contentShape(shape)
            .scaleEffect(!reduceMotion && configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
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
