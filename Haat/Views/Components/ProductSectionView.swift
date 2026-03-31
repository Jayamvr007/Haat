import SwiftUI

struct ProductSectionView: View {
    let title: String
    let items: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.haatTextDark)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View all")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.haatRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.haatRed.opacity(0.12)))
                }
            }
            .padding(.horizontal, 16)
            
            // Horizontal Product Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        ProductCard(product: item)
                    }
                    
                    // "View All" card at end of carousel (per Figma annotation)
                    viewAllCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .padding(.bottom, 16)
    }
    
    private var viewAllCard: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.haatRed.opacity(0.08))
                    .frame(width: 24, height: 24)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.haatRed)
                    
            }
            
            Text("View All")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.haatRed)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(width: 100)
    }
}
