import SwiftUI

struct ProductDetailSheet: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    
    var quantity: Int {
        cartManager.quantity(for: product.id ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // Large Product Image
                    if let imageUrl = product.productImages?.first?.fullUrl {
                        CachedAsyncImage(url: imageUrl) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ShimmerPlaceholder(height: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .background(Color.haatSearchBg)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // Badges
                    HStack(spacing: 8) {
                        if product.notAvailable == true {
                            badgePill(text: "Unavailable", color: .gray)
                        }
                        if let deal = product.productDeal?.name?.localized, !deal.isEmpty {
                            badgePill(text: deal.uppercased(), color: Color(hex: "00B26E"))
                        }
                        if let discount = product.discountPercentage, discount > 0 {
                            badgePill(text: "-\(Int(discount))%", color: .haatRed)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Product Name
                    Text(product.name?.localized ?? "Product")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.haatTextDark)
                        .padding(.horizontal, 20)
                    
                    // Description
                    if let desc = product.description?.localized, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(.haatTextLight)
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                    }
                    
                    // Weight
                    if let weight = product.weightToPresent, !weight.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 13))
                                .foregroundColor(.haatTextLight)
                            Text(weight)
                                .font(.system(size: 14))
                                .foregroundColor(.haatTextLight)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Price Section
                    HStack(alignment: .bottom, spacing: 8) {
                        Text("₪\(String(format: "%.1f", product.currentPrice))")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(product.hasDiscount ? .haatRed : .haatTextDark)
                        
                        if product.hasDiscount {
                            Text("₪\(String(format: "%.1f", product.basePrice ?? 0.0))")
                                .font(.system(size: 16))
                                .strikethrough()
                                .foregroundColor(.haatTextLight)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 20)
                }
                .padding(.bottom, 16)
            }
            
            // Bottom Add to Cart area
            VStack(spacing: 0) {
                Divider()
                
                if quantity > 0 {
                    // Stepper
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                cartManager.removeItem(productId: product.id ?? 0)
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.haatRed)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("\(quantity)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.haatRed)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                cartManager.addItem(productId: product.id ?? 0)
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.haatRed)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                } else {
                    // Large Add button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cartManager.addItem(productId: product.id ?? 0)
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                            Text("Add to Cart")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(product.notAvailable == true ? Color.gray : Color.haatRed)
                        .cornerRadius(14)
                    }
                    .disabled(product.notAvailable == true)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
    
    private func badgePill(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .cornerRadius(6)
    }
}
