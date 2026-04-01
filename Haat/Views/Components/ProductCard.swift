import SwiftUI

struct ProductCard: View {
    let product: Product
    var width: CGFloat? = 140
    @EnvironmentObject var cartManager: CartManager
    @State private var animateAdd: Bool = false
    @State private var showDetail: Bool = false
    @State private var imageRect: CGRect = .zero
    
    var quantity: Int {
        cartManager.quantity(for: product.id ?? 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product Image
            ZStack(alignment: .bottomLeading) {
                if let imageUrl = product.productImages?.first?.fullUrl {
                    CachedAsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ShimmerPlaceholder()
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                } else {
                    ShimmerPlaceholder(height: 100)
                        .padding(8)
                }
                
                // Top Badges
                VStack(alignment: .leading, spacing: 4) {
                    if product.notAvailable == true {
                        Text("Unavailable")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(4)
                    } else if let deal = product.productDeal?.name?.localized, !deal.isEmpty {
                        Text(deal.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "00B26E")) // Match the green deal badge
                            .cornerRadius(4)
                    } else if let discount = product.discountPercentage, discount > 0 {
                        Text("-\(Int(discount))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.haatRed)
                            .cornerRadius(4)
                    }
                }
                .padding(.leading, 8)
                .padding(.bottom, 4)
            }
            .background(
                GeometryReader { geo in
                    let frame = geo.frame(in: .global)
                    Color.clear
                        .onAppear { imageRect = frame }
                        .onChange(of: frame) { newFrame in
                            imageRect = newFrame
                        }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                showDetail = true
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Price Row
                HStack(alignment: .bottom, spacing: 4) {
                    Text("₪\(String(format: "%.1f", product.currentPrice))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(product.hasDiscount ? .haatRed : .haatTextDark)
                    
                    if product.hasDiscount {
                        Text("₪\(String(format: "%.1f", product.basePrice ?? 0.0))")
                            .font(.system(size: 12))
                            .strikethrough()
                            .foregroundColor(.haatTextLight)
                    }
                }
                
                // Name
                Text(product.name?.localized ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(product.notAvailable == true ? .haatTextLight : .haatTextDark)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Weight
                if let weight = product.weightToPresent, !weight.isEmpty {
                    Text(weight)
                        .font(.system(size: 12))
                        .foregroundColor(.haatTextLight)
                } else {
                    // Empty space holder to keep heights consistent
                    Text(" ")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            
            Spacer()
            
            // Add to Cart / Stepper
            // Cart actions
            cartActionView
            .padding(.bottom, 10)
        }
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            ProductDetailSheet(product: product)
                .environmentObject(cartManager)
        }
    }
    
    @ViewBuilder
    private var cartActionView: some View {
        Group {
            if quantity > 0 {
                // Stepper
                HStack(spacing: 0) {
                    Button(action: handleSub) {
                        Text("—")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.haatRed)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Text("\(quantity)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.haatTextDark)
                        .fixedSize()
                    
                    Button(action: handleAddSecondary) {
                        Text("+")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.haatRed)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 36)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 10)
                .transition(.scale.combined(with: .opacity))
            } else {
                // Single + button
                Button(action: handleAddInitial) {
                    Text("+")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.haatRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 10)
                .scaleEffect(animateAdd ? 1.15 : 1.0)
                .transition(.scale.combined(with: .opacity))
                .disabled(product.notAvailable == true)
                .opacity(product.notAvailable == true ? 0.4 : 1.0)
            }
        }
    }
    
    // Actions
    
    private func handleSub() {
        withAnimation(.easeInOut(duration: 0.2)) {
            cartManager.removeItem(productId: product.id ?? 0)
        }
    }
    
    private func handleAddSecondary() {
        withAnimation(.easeInOut(duration: 0.2)) {
            cartManager.addItem(productId: product.id ?? 0)
        }
        triggerFlyAnimation()
        triggerHaptic()
    }
    
    private func handleAddInitial() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            cartManager.addItem(productId: product.id ?? 0)
            animateAdd = true
        }
        triggerFlyAnimation()
        triggerHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateAdd = false
        }
    }
    
    private func triggerFlyAnimation() {
        if let imageUrl = product.productImages?.first?.fullUrl {
            cartManager.addFlyingItem(imageUrl: imageUrl.absoluteString, startRect: imageRect)
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
