import SwiftUI

struct AnimatedSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.haatPlaceholder)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search products", text: $text)
                .focused($isFocused)
                .foregroundColor(.haatTextDark)
                .font(.system(size: 14))
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.haatPlaceholder)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.haatSearchBg)
        .cornerRadius(24)
        .scaleEffect(isFocused ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}
