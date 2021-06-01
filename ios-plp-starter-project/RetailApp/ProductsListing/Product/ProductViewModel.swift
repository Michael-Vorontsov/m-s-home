
import Foundation

protocol ProductViewModel {
    var name: Observable<String> { get }
    var image: Observable<UIImage> { get }
    var price: Observable<NSAttributedString> { get }
    var badge: Observable<UIImage?> { get }

    var didSelected: Observable<Void> { get }

    func loadImage()
}

final class ProductViewModelImplementation: ProductViewModel {
    let name: Observable<String>
    let image: Observable<UIImage>
    let badge: Observable<UIImage?> = .init(nil)

    let price: Observable<NSAttributedString>
    let didSelected: Observable<Void> = .init(Void())
    var badgeImage: Observable<UIImage?> = .init(nil)

    private static var imageCache: [String: UIImage] = [:]

    private let imageService: ImageService
    private let priceFormatter: PriceFormatter
    private let imageKey: String
    private var isImageLoaded: Bool = false

    init(name: String, imageKey: String, price: Price, imageService: ImageService, priceFormatter: PriceFormatter) {
        self.priceFormatter = priceFormatter
        self.imageService = imageService
        self.imageKey = imageKey

        self.name = .init(name)
        self.image = .init( #imageLiteral(resourceName: "Placeholder"))
        self.price = .init(priceFormatter.formatPrice(price))
    }

    func loadImage() {
        guard isImageLoaded == false else { return }

        let key = imageKey

        if let cachedImage = Self.imageCache[key] {
            image.value = cachedImage
            isImageLoaded = true
            return
        }

        self.imageService.downloadImage(key: key) {[weak self]  result in
            do {
                let downloadedImage = try result.unwrapped()
                Self.imageCache[key] = downloadedImage
                self?.image.value = downloadedImage
                self?.isImageLoaded = true
            } catch  {
                print("error fetching image for key: \(key)")
            }
        }

    }

}
