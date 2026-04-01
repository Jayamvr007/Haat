import Foundation

struct FlyingItem: Identifiable, Equatable {
    let id = UUID()
    let imageUrl: String
    let startRect: CGRect
}

@MainActor
class CartManager: ObservableObject {
    @Published var cartItems: [Int: Int] = [:] // ProductID -> Quantity
    @Published var flyingItems: [FlyingItem] = []
    
    func addItem(productId: Int) {
        cartItems[productId, default: 0] += 1
    }
    
    func removeItem(productId: Int) {
        guard let count = cartItems[productId], count > 0 else { return }
        if count == 1 {
            cartItems.removeValue(forKey: productId)
        } else {
            cartItems[productId] = count - 1
        }
    }
    
    func quantity(for productId: Int) -> Int {
        return cartItems[productId] ?? 0
    }
    
    var totalItems: Int {
        return cartItems.values.reduce(0, +)
    }
    
    
    func addFlyingItem(imageUrl: String, startRect: CGRect) {
        let item = FlyingItem(imageUrl: imageUrl, startRect: startRect)
        flyingItems.append(item)
    }
    
    func removeFlyingItem(_ item: FlyingItem) {
        flyingItems.removeAll { $0.id == item.id }
    }
}
