import SwiftUI

struct ProductGridSectionView: View {
    let title: String
    let items: [Product]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.haatTextDark)
                .padding(.horizontal, 16)
            
            // Vertical 3-column Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    ProductCard(product: item, width: nil)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 0)
    }
}
