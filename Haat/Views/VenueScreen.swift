import SwiftUI

private struct SectionOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct CartIconRectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct VenueScreen: View {
    @StateObject private var viewModel = VenueViewModel()
    @StateObject private var cartManager = CartManager()
    @State private var showSearchOverlay = false
    @State private var cartFillLevel: CGFloat = 0.0
    @State private var scrollOffset: CGFloat = 0
    @State private var showStickyHeader = false
    @State private var searchPlaceholder = "Search products"
    @State private var cartIconRect: CGRect = .zero
    
    var body: some View {
        ZStack {
            // Main App Content Layer
            ZStack(alignment: .bottom) {
                Color.haatBackground.edgesIgnoringSafeArea(.all)
            
            ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Hero Image
                    ZStack(alignment: .top) {
                        // Parallax Banner Image
                        GeometryReader { geo in
                            let minY = geo.frame(in: .global).minY
                            let isScrolledUp = minY > 0
                            
                            if let bannerUrl = viewModel.venueInfo?.banner?.images?.first?.fullUrl {
                                CachedAsyncImage(url: bannerUrl) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ShimmerPlaceholder()
                                }
                                .frame(width: geo.size.width,
                                       height: isScrolledUp ? 220 + minY : 220)
                                .clipped()
                                .offset(y: isScrolledUp ? -minY : 0)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: geo.size.width,
                                           height: isScrolledUp ? 220 + minY : 220)
                                    .clipped()
                                    .offset(y: isScrolledUp ? -minY : 0)
                                    .shimmering()
                            }
                        }
                        .frame(height: 220)
                    }
                    .id("scrollTop")
                    
                    // Navigation logic
                    if viewModel.isLoading && viewModel.venueInfo == nil {
                        loadingView
                            .offset(y: -30)
                    } else if let error = viewModel.errorMessage, viewModel.venueInfo == nil {
                        errorView(error: error)
                    } else {
                        VStack(spacing: 0) {
                            // Venue Card (overlaps hero)
                            VenueInfoCard(venue: viewModel.venueInfo, delivery: viewModel.deliveryDetails)
                                .padding(.horizontal, 16)
                                .offset(y: -38)
                                .padding(.bottom, -14)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: SectionOffsetPreferenceKey.self,
                                            value: ["venueCard": geo.frame(in: .global).minY]
                                        )
                                    }
                                )
                            
                            // Allergy Notice
                            VStack(alignment: .leading, spacing: 4) {
                                Text("For your attention")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.haatTextDark)
                                Text("All our products are manufactured on shared machines and in the same production environment, so there is a risk of cross-contamination with allergens.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.haatTextLight)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .padding(.bottom, 16)
                            
                            // Menu Sections
                            ForEach(viewModel.filteredMenuSections, id: \.uniqueId) { section in
                                let sectionKey = section.name ?? section.type ?? "section"
                                Group {
                                    if section.type == "Categories" {
                                        if !(section.categories ?? []).isEmpty {
                                            CategoryGridView(
                                                title: section.name ?? "Available Categories",
                                                categories: section.categories ?? []
                                            )
                                        }
                                    } else if section.type == "Footer" {
                                        footerButton
                                    } else if section.type == "TopSelling" {
                                        if !(section.items ?? []).isEmpty {
                                            ProductGridSectionView(
                                                title: "You might also want",
                                                items: section.items ?? []
                                            )
                                        }
                                    } else {
                                        if !(section.items ?? []).isEmpty {
                                            ProductSectionView(
                                                title: section.name ?? "",
                                                items: section.items ?? []
                                            )
                                        }
                                    }
                                }
                                .id(sectionKey)
                            } // end ForEach
                            
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
            .onPreferenceChange(SectionOffsetPreferenceKey.self) { values in
                if let venueCardY = values["venueCard"] {
                    // When venue card scrolls above ~110pt (behind the nav bar)
                    let shouldShow = venueCardY < 110
                    if self.showStickyHeader != shouldShow {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.showStickyHeader = shouldShow
                            self.searchPlaceholder = shouldShow
                                ? (viewModel.venueInfo?.name?.localized ?? "Search")
                                : "Search products"
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
            
            // Bottom Floating Elements
            VStack(spacing: 16) {
                // Floating Action Buttons
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            scrollProxy.scrollTo("scrollTop", anchor: .top)
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.haatRed)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.haatRed, lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for support
                    }) {
                        Image("haat_call")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.haatRed)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, cartManager.totalItems > 0 ? 0 : 24)
                
                // Free Delivery Tracker
                if cartManager.totalItems > 0 {
                    freeDeliveryTracker
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Cart Banner
                if cartManager.totalItems > 0 {
                    cartBanner
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: cartManager.totalItems)
                }
            }
            } // end ScrollViewReader
            
            // Sticky Navigation Bar
            if !showSearchOverlay {
                VStack {
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.haatTextDark)
                                .frame(width: 40, height: 40)
                                .background(showStickyHeader ? Color.clear : Color.white)
                                .clipShape(Circle())
                                .shadow(color: showStickyHeader ? .clear : .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        
                        // Tappable Search Bar (opens overlay)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showSearchOverlay = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.haatPlaceholder)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(searchPlaceholder)
                                    .foregroundColor(showStickyHeader ? .haatTextDark : .haatPlaceholder)
                                    .font(.system(size: 16, weight: showStickyHeader ? .regular : .regular))
                                    .lineLimit(1)
                                    .id(searchPlaceholder) // Forces SwiftUI to see it as a new view
                                    .transition(.asymmetric(
                                        insertion: .push(from: .trailing),
                                        removal: .opacity
                                    ))
                                
                                Spacer()
                                
                                // Venue icon on right side when sticky
                                if showStickyHeader,
                                   let iconUrl = viewModel.venueInfo?.iconImage?.fullUrl {
                                    CachedAsyncImage(url: iconUrl) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle().fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .transition(.push(from: .trailing))
                                }
                            }
                            .frame(height: 40)
                            .padding(.leading, 12)
                            .padding(.trailing, showStickyHeader ? 0 : 12)
                            .background(showStickyHeader ? Color.haatSearchBg : Color.white.opacity(0.92))
                            .cornerRadius(24)
                        }
                        
                        Button(action: {}) {
                            Image("share")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .frame(width: 40, height: 40)
                                .background(showStickyHeader ? Color.clear : Color.white)
                                .clipShape(Circle())
                                .shadow(color: showStickyHeader ? .clear : .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 54)
                    .padding(.bottom, 8)
                    .background(
                        (showStickyHeader ? Color.white : Color.clear)
                            .shadow(color: showStickyHeader ? .black.opacity(0.06) : .clear, radius: 4, x: 0, y: 2)
                    )
                    .animation(.easeInOut(duration: 0.3), value: showStickyHeader)
                    Spacer()
                }
                .zIndex(3)
            }
            
            // Search Overlay
            if showSearchOverlay {
                SearchOverlayView(
                    isPresented: $showSearchOverlay,
                    searchText: $viewModel.searchQuery,
                    searchResults: viewModel.filteredMenuSections
                )
                .transition(.move(edge: .trailing))
                .zIndex(4)
            }
        }
        .onPreferenceChange(CartIconRectKey.self) { rect in
            cartIconRect = rect
        }
        
        // FLYING ANIMATION LAYER (Top-most Z-Index)
        ForEach(cartManager.flyingItems) { item in
            FlyingCartItemView(item: item, targetRect: cartIconRect) {
                cartManager.removeFlyingItem(item)
            }
        }
    }
    .environmentObject(cartManager)
    .edgesIgnoringSafeArea(.top)
    .onAppear {
        Task {
            await viewModel.loadData()
        }
    }
    }
    
    // Shimmer Loading
    private var loadingView: some View {
        VStack(spacing: 20) {
            // Venue card shimmer
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ShimmerPlaceholder(width: 48, height: 48, cornerRadius: 12)
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerPlaceholder(width: 160, height: 20)
                        ShimmerPlaceholder(width: 120, height: 14)
                    }
                    Spacer()
                }
                ShimmerPlaceholder(height: 60)
                ShimmerPlaceholder(height: 40, cornerRadius: 8)
                ShimmerPlaceholder(height: 40, cornerRadius: 8)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            
            // Product section shimmer
            VStack(alignment: .leading, spacing: 12) {
                ShimmerPlaceholder(width: 140, height: 20)
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { _ in
                            ShimmerPlaceholder(width: 140, height: 200, cornerRadius: 8)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    // Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.haatRed)
            Text("Oops! Something went wrong.")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.haatTextDark)
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.haatTextLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                Task { await viewModel.loadData() }
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.haatRed)
            .cornerRadius(8)
        }
        .padding(.top, 60)
    }
    
    // Footer
    private var footerButton: some View {
        Button(action: {}) {
            HStack {
                Spacer()
                Text("I'm looking for something else")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.haatRed)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(Color.haatRed.opacity(0.08))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
    
    // Cart Banner
    private var cartBanner: some View {
        Button(action: {
            // Action to view order
        }) {
            GeometryReader { geo in
                // Sweeping Red Layer (Masked)
                cartBannerContent(
                    bgColor: .haatRed,
                    textColor: .white,
                    circleBg: .white,
                    circleText: .haatRed
                )
                .mask(
                    Rectangle()
                        .frame(width: geo.size.width * cartFillLevel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
            }
            .frame(height: 52)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: -4)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            cartFillLevel = 0.0
            withAnimation(.easeOut(duration: 0.5)) {
                cartFillLevel = 1.0
            }
        }
        .onChange(of: cartManager.totalItems) { _ in
            withAnimation(.none) { cartFillLevel = 0.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.5)) {
                    cartFillLevel = 1.0
                }
            }
        }
    }
    
    @State private var bounceCartCount: Bool = false
    
    private func cartBannerContent(bgColor: Color, textColor: Color, circleBg: Color, circleText: Color) -> some View {
        HStack {
            // Circle with total quantity
            ZStack {
                Circle()
                    .fill(circleBg)
                    .frame(width: 24, height: 24)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: CartIconRectKey.self, value: geo.frame(in: .global))
                        }
                    )
                Text("\(cartManager.totalItems)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(circleText)
            }
            .scaleEffect(bounceCartCount ? 1.3 : 1.0)
            .onChange(of: cartManager.totalItems) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    bounceCartCount = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        bounceCartCount = false
                    }
                }
            }
            
            Text("View your order")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textColor)
                .padding(.leading, 8)
            
            Spacer()
            
            // Format price dynamically, remove decimals if flat
            let total = viewModel.calculateTotal(for: cartManager.cartItems)
            Text("₪\(total, specifier: total.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f")")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .background(bgColor)
    }
    
    @ViewBuilder
    private var freeDeliveryTracker: some View {
        let subtotal = viewModel.calculateTotal(for: cartManager.cartItems)
        let remaining = max(0, viewModel.freeDeliveryThreshold - subtotal)
        let progress = min(1.0, subtotal / viewModel.freeDeliveryThreshold)
        
        Group {
            VStack(spacing: 8) {
                HStack {
                    if remaining > 0 {
                        Group {
                            Text("Add ") +
                            Text("₪\(String(format: "%.1f", remaining))").bold() +
                            Text(" more for ") +
                            Text("Free Delivery!").bold()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.haatTextDark)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.haatGreen)
                            Text("🎉 Free Delivery Unlocked!")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.haatGreen)
                        }
                    }
                    
                    Spacer()
                    
                    Text("₪\(String(format: "%.1f", subtotal))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.haatTextDark)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(remaining > 0 ? Color.haatRed.opacity(0.6) : Color.haatGreen)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}
