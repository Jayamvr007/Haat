import SwiftUI

struct CategoryJumpBar: View {
    let categories: [String]
    @Binding var selected: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = category
                            }
                            onSelect(category)
                            withAnimation {
                                proxy.scrollTo(category, anchor: .center)
                            }
                        }) {
                            Text(category)
                                .font(.system(size: 13, weight: selected == category ? .bold : .regular))
                                .foregroundColor(selected == category ? .white : .haatTextDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selected == category ? Color.haatRed : Color.haatSearchBg)
                                .cornerRadius(20)
                        }
                        .id(category)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .onChange(of: selected) { newVal in
                withAnimation {
                    proxy.scrollTo(newVal, anchor: .center)
                }
            }
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
