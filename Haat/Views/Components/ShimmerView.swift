import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.white.opacity(0.4)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .white, .clear]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .rotationEffect(.degrees(20))
                                .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                        )
                }
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

// A generic rectangular placeholder that shimmers
struct ShimmerPlaceholder: View {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 8

    var body: some View {
        Color.gray.opacity(0.2)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shimmering()
    }
}
