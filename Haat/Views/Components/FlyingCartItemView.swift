import SwiftUI

struct FlyingCartItemView: View {
    let item: FlyingItem
    let targetRect: CGRect
    let onComplete: () -> Void
    
    @State private var animate = false
    @State private var opacity: Double = 1.0
    
    private var effectiveTarget: CGRect {
        if targetRect == .zero {
            // Fallback: Left side of screen where the circle badge appears
            let screen = UIScreen.main.bounds
            // 16 padding + 12 half-width = 28
            return CGRect(x: 28, y: screen.height - 80, width: 24, height: 24)
        }
        return targetRect
    }
    
    var body: some View {
        Group {
            CachedAsyncImage(url: URL(string: item.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3)) // Fallback shape
            }
        }
        .frame(width: animate ? effectiveTarget.width : item.startRect.width,
               height: animate ? effectiveTarget.height : item.startRect.height)
        .clipShape(RoundedRectangle(cornerRadius: animate ? effectiveTarget.width / 2 : 8))
        .opacity(opacity)
        .position(x: animate ? effectiveTarget.midX : item.startRect.midX,
                  y: animate ? effectiveTarget.midY : item.startRect.midY)
        .onAppear {
            // Trigger the fly animation with a production-grade response
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                animate = true
            }
            
            // Fade out right before it fully hits the target
            withAnimation(.linear(duration: 0.1).delay(0.45)) {
                opacity = 0.0
            }
            
            // Remove from state when complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onComplete()
            }
        }
    }
}
