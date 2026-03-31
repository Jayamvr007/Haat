import SwiftUI

struct SearchOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    var searchResults: [MenuSection]
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack(spacing: 12) {
                Button(action: {
                    searchText = ""
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.haatRed)
                }
                
                // Search Input
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.haatPlaceholder)
                        .font(.system(size: 16))
                    
                    TextField("Search products", text: $searchText)
                        .focused($isSearchFocused)
                        .foregroundColor(.haatTextDark)
                        .font(.system(size: 15))
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.haatPlaceholder)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.haatSearchBg)
                .cornerRadius(24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 54) // Safe area padding to make touch target accessible
            .padding(.bottom, 12)
            
            Divider()
            
            // Empty State
            if searchText.isEmpty {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "text.page.badge.magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.35))
                    
                    Text("Type in the search bar the name of the\nitem you're looking for")
                        .font(.system(size: 14))
                        .foregroundColor(.haatTextLight)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Spacer()
                Spacer()
            } else if searchResults.filter({ !($0.items ?? []).isEmpty }).isEmpty {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.35))
                    
                    Text("No results found for '\(searchText)'")
                        .font(.system(size: 14))
                        .foregroundColor(.haatTextLight)
                }
                
                Spacer()
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(searchResults, id: \.uniqueId) { section in
                            if let items = section.items, !items.isEmpty {
                                ProductGridSectionView(title: section.name ?? "Results", items: items)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .onAppear {
            // Delay keyboard focus until the view slide-in animation finishes to prevent UI lag
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isSearchFocused = true
            }
        }
        .onDisappear {
            isSearchFocused = false
        }
    }
}
