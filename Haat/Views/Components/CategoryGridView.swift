import SwiftUI

struct CategoryGridView: View {
    let title: String
    let categories: [MenuCategory]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.haatTextDark)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(categories) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .padding(.bottom, 16)
    }
}

struct CategoryCard: View {
    let category: MenuCategory
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageUrl = category.image?.fullUrl {
                CachedAsyncImage(url: imageUrl) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                }
                .frame(height: 136)
                .frame(maxWidth: .infinity)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.haatSearchBg)
                    .frame(height: 136)
            }
            
            HStack {
                Text(category.name ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.haatTextDark)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            .background(Color(hex: "F3F5EE").opacity(0.7))
        }
        .frame(height: 136)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}
