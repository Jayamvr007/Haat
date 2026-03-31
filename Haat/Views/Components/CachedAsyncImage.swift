import SwiftUI

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        if let uiImage = uiImage {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
                .onAppear {
                    loadImage()
                }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        let cacheKey = url.absoluteString as NSString
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            self.uiImage = cachedImage
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                   let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: cacheKey)
                    await MainActor.run {
                        self.uiImage = image
                    }
                }
            } catch {
                print("Error loading image from \(url): \(error)")
            }
        }
    }
}
