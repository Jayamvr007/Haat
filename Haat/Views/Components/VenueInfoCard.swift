import SwiftUI

struct VenueInfoCard: View {
    let venue: VenueInfo?
    let delivery: DeliveryDetails?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Top Section
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    // Logo
                    if let iconUrl = venue?.iconImage?.fullUrl {
                        CachedAsyncImage(url: iconUrl) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ShimmerPlaceholder(cornerRadius: 28)
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 56, height: 56)
                    }
                    
                    Spacer()
                    
                    // Heart
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 24))
                            .foregroundColor(.haatTextDark)
                    }
                }
                
                HStack(alignment: .center) {
                    Text(venue?.name?.localized ?? "")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.haatTextDark)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.haatTextDark)
                }
                .padding(.top, 4)
                
                Text(venue?.location?.address ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.haatTextLight)
                
                HStack(spacing: 4) {
                    Text("Open")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.haatGreen)
                    Text("until 23:00")
                        .font(.system(size: 16))
                        .foregroundColor(.haatTextLight)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Divider
            Rectangle()
                .fill(Color.haatBorder)
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Metrics Row
            HStack(alignment: .top, spacing: 0) {
                // Delivery
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.haatSearchBg)
                            .frame(width: 48, height: 48)
                        Image("scooter") // SF Symbol for scooter
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.haatTextDark)
                    }
                    
                    if let delivery = delivery {
                        VStack(spacing: 6) {
                            Text(delivery.deliveryTime ?? "N/A")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.haatTextDark)
                            
                            Text("₪\(Int(delivery.deliveryFee?.finalPrice ?? 0))")
                                .font(.system(size: 15))
                                .foregroundColor(.haatTextLight)
                        }
                    } else {
                        ShimmerPlaceholder(width: 60, height: 14)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Schedule
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.haatSearchBg)
                            .frame(width: 48, height: 48)
                        Image("clock")
                            .font(.system(size: 32))
                            .foregroundColor(.haatTextDark)
                    }
                    
                    VStack(spacing: 6) {
                        Text("Sun")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.haatTextDark)
                        
                        Text("8:00 - 23:00")
                            .font(.system(size: 15))
                            .foregroundColor(.haatTextLight)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Rating
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.haatSearchBg)
                            .frame(width: 48, height: 48)
                        Image( "star")
                            .font(.system(size: 20))
                            .foregroundColor(.haatTextDark)
                    }
                    
                    if let rating = venue?.rating {
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", rating.ratings ?? 0.0))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.haatTextDark)
                                
                                Text("(\(rating.numberOfRatings ?? ""))")
                                    .font(.system(size: 15))
                                    .foregroundColor(.haatTextLight)
                            }
                            
                            if rating.topRated == true {
                                HStack(spacing: 4) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 10))
                                    Text("Top rated")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.haatRed)
                                .cornerRadius(4)
                            }
                        }
                    } else {
                        ShimmerPlaceholder(width: 60, height: 14)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image("sale")
                        .font(.system(size: 24, weight: .bold))
                        
                    
                    Group {
                        Text("-20% Sale")
                            .font(.system(size: 15, weight: .bold))
                        + Text(" on part of the items")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.haatTextDark)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.haatSearchBg)
                .cornerRadius(12)
                
                HStack(spacing: 12) {
                    Image("scooter2")
                        .resizable()
                        
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        
                    
                    Group {
                        Text("₪0 Delivery Fee")
                            .font(.system(size: 15, weight: .bold))
                        + Text(" on orders above ₪80")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(.haatTextDark)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.haatSearchBg)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .cornerRadius(24) // Using a more prominent corner radius
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        
    }
}
