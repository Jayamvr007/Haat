import Foundation

@MainActor
class VenueViewModel: ObservableObject {
    @Published var venueInfo: VenueInfo?
    @Published var deliveryDetails: DeliveryDetails?
    @Published var menuResponse: MenuResponse?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var searchQuery = ""
    
    private let venueInfoURL = "https://user-new-app-staging.internal.haat.delivery/api/venue/5230/info?isByLocation=true&userLatitude=32.53176498413086&userLongitude=35.149749755859375"
    private let deliveryURL = "https://user-new-app-staging.internal.haat.delivery/api/venue/5230/delivery-details?isByLocation=true&userLatitude=32.53176498413086&userLongitude=35.149749755859375"
    private let menuURL = "https://user-new-app-staging.internal.haat.delivery/api/venue/5230/menu"
    
    let freeDeliveryThreshold: Double = 80.0

    
    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchVenue: VenueInfo = try NetworkManager.shared.fetch(urlString: venueInfoURL)
            async let fetchDelivery: DeliveryDetails = try NetworkManager.shared.fetch(urlString: deliveryURL)
            async let fetchMenu: MenuResponse = try NetworkManager.shared.fetch(urlString: menuURL)
            
            let (venue, delivery, menu) = try await (fetchVenue, fetchDelivery, fetchMenu)
            self.venueInfo = venue
            self.deliveryDetails = delivery
            self.menuResponse = menu
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Failed to load data: \(error)")
        }
        
        isLoading = false
    }
    
    var filteredMenuSections: [MenuSection] {
        guard let sections = menuResponse?.sections else { return [] }
        if searchQuery.isEmpty {
            return sections
        }
        
        let lowerQuery = searchQuery.lowercased()
        
        return sections.compactMap { section in
            let filteredItems = section.items?.filter { item in
                (item.name?.localized ?? "").lowercased().contains(lowerQuery)
            } ?? []
            if !filteredItems.isEmpty {
                return MenuSection(
                    id: section.id,
                    type: section.type,
                    name: section.name,
                    items: filteredItems,
                    categories: []
                )
            }
            return nil
        }
    }
    
    // Helper to calculate total price based on cart items
    func calculateTotal(for cartItems: [Int: Int]) -> Double {
        guard let sections = menuResponse?.sections else { return 0.0 }
        
        var total = 0.0
        let allProducts = sections.flatMap { $0.items ?? [] }
        
        for (productId, quantity) in cartItems {
            if let product = allProducts.first(where: { $0.id == productId }) {
                total += product.currentPrice * Double(quantity)
            }
        }
        
        return total
    }
}
