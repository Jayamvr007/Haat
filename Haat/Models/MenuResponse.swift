import Foundation

struct MenuResponse: Codable {
    let sections: [MenuSection]?
}

struct MenuSection: Codable, Identifiable {
    let id: Int?
    let type: String?
    let name: String?
    let items: [Product]?
    let categories: [MenuCategory]?
    
    var uniqueId: String {
        return "\(id ?? 0)-\(type ?? "")-\(name ?? "")"
    }
}

struct Product: Codable, Identifiable {
    let id: Int?
    let name: LocalizedString?
    let basePrice: Double?
    let discountPrice: Double?
    let discountPercentage: Double?
    let productImages: [ImageInfo]?
    let notAvailable: Bool?
    let score: Double?
    let description: LocalizedString?
    let weightToPresent: String?
    let productDeal: ProductDeal?
    let shareData: ShareData?
    
    var currentPrice: Double {
        return discountPrice ?? basePrice ?? 0.0
    }
    
    var hasDiscount: Bool {
        if let discount = discountPrice, let base = basePrice {
            return discount < base
        }
        return false
    }
}

struct MenuCategory: Codable, Identifiable {
    let id: Int?
    let name: String?
    let image: ImageInfo?
}

struct ProductDeal: Codable {
    let name: LocalizedString?
    let description: String?
}

struct ShareData: Codable {
    let message: String?
    let url: String?
}
