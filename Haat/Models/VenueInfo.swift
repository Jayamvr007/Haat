import Foundation

struct LocalizedString: Codable {
    let enUS: String?
    let he: String?
    let ar: String?
    
    enum CodingKeys: String, CodingKey {
        case enUS = "en-US"
        case he
        case ar
    }
    
    var localized: String {
        return enUS ?? he ?? ar ?? ""
    }
}

struct ImageInfo: Codable {
    let id: Int?
    let serverImageUrl: String?
    let smallImageUrl: String?
    let blurhash: String?
    
    var fullUrl: URL? {
        guard let path = serverImageUrl, !path.isEmpty else { return nil }
        return URL(string: "https://im-staging.haat.delivery/" + path)
    }
}

// Venue Info
struct VenueInfo: Codable, Identifiable {
    let id: Int?
    let type: String?
    let name: LocalizedString?
    let rating: VenueRating?
    let location: VenueLocation?
    let status: VenueStatus?
    let iconImage: ImageInfo?
    let banner: VenueBanner?
    let noticeMessage: NoticeMessage?
    
    // Newly mapped API fields
    let phoneNumbers: [String]?
    let workingHours: VenueWorkingHours?
    let franchiseBranches: FranchiseBranches?
    let checkoutStatus: CheckoutStatus?
    let notes: [VenueNote]?
    let shareData: ShareData?
}

struct VenueRating: Codable {
    let ratings: Double?
    let numberOfRatings: String?
    let topRated: Bool?
    let isNew: Bool?
}

struct VenueLocation: Codable {
    let areaId: Int?
    let address: String?
    let longitude: Double?
    let latitude: Double?
}

struct VenueStatus: Codable {
    let status: Int?
    let is24Hours: Bool?
}

struct VenueBanner: Codable {
    let timer: Int?
    let images: [ImageInfo]?
}

struct NoticeMessage: Codable {
    let title: String?
    let message: String?
}

// MARK: - Extended Venue Structures
struct VenueWorkingHours: Codable {
    let isOpened24Hours: Bool?
    let isClosed24Hours: Bool?
    let currentWorkingHour: WorkingHour?
    let workingHours: [WorkingHour]?
}

struct WorkingHour: Codable {
    let dayOfWeek: Int?
    let fromHour: Int?
    let toHour: Int?
    let type: Int?
}

struct FranchiseBranches: Codable {
    let title: String?
    let branches: [Branch]?
}

struct Branch: Codable {
    let id: Int?
    let name: String?
    let iconImage: ImageInfo?
    let distance: String?
    let rating: VenueRating?
    let status: VenueStatus?
    let isClosestBranch: Bool?
}

struct CheckoutStatus: Codable {
    let enabled: Bool?
    let buttonTitle: String?
}

struct VenueNote: Codable {
    let timeout: Int?
    let hide: Bool?
    let text: String?
    let type: String?
}
