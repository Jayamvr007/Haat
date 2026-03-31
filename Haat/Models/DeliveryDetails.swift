import Foundation

struct DeliveryDetails: Codable {
    let deliveryTime: String?
    let deliveryFee: DeliveryFee?
    let deliveryAvailabilityIcon: String?
}

struct DeliveryFee: Codable {
    let finalPrice: Double?
    let strikedPrice: Double?
}
