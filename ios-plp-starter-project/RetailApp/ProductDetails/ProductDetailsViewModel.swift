import Foundation
import UIKit

protocol ProductRequest {
  var id: String { get }
  var price: Price { get }
  var name: String { get }
}

final class ProductDetailsViewModel {
  private let priceFormatter: PriceFormatter
  private let informationFormatter: InformationFormatter
  private let productDetailsService: ProductDetailsService
  private let imageService: ImageService

  let name: Observable<String>
  let information: Observable<String>
  let image: Observable<UIImage>
  let price: Observable<NSAttributedString>
  let errorMessage: Observable<String?> = .init(nil)

  private var productImage: UIImage?

  private var productDetails: ProductDetails? {
    didSet {
      guard let value = productDetails else {
        return
      }
      updateObservables(productDetails: value)
      downloadProductImage(productDetails: value)
    }
  }

  init(productRequest: ProductRequest, listingImage: UIImage?, productDetailsService: ProductDetailsService, imageService: ImageService, priceFormatter: PriceFormatter = PriceFormatterImplementation(), informationFormatter: InformationFormatter = InformationFormatterImplementation()) {
    self.productDetailsService = productDetailsService
    self.priceFormatter = priceFormatter
    self.informationFormatter = informationFormatter
    self.imageService = imageService
    self.price = Observable<NSAttributedString>(priceFormatter.formatPrice(productRequest.price))
    self.name = Observable<String>(productRequest.name)
    self.information = Observable<String>("")
    self.image = Observable<UIImage>(listingImage ?? #imageLiteral(resourceName: "Placeholder"))
    getProduct(id: productRequest.id)
  }

  private func updateObservables(productDetails: ProductDetails) {
    price.value = priceFormatter.formatPrice(productDetails.price)
    name.value = productDetails.name
    information.value = informationFormatter.formatInformation(productDetails.information)
  }

  private func getProduct(id: String) {
    productDetailsService.getProduct(id: id) { [weak self] result in
      do {
        self?.productDetails = try result.unwrapped()
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  private func downloadProductImage(productDetails: ProductDetails) {
    guard productImage == nil else {
      return
    }

    imageService.downloadImage(key: productDetails.imageKey) { [weak self] result in
      guard let strongSelf = self else {
        return
      }
      do {
        let image = try result.unwrapped()
        strongSelf.image.value = image
      } catch {
        /**
         For some reason ImageService cannot fetch images for ProductDetails keys.
         So I changes logit to present error about it.
         */
        strongSelf.errorMessage.value = "Failed to fetch image: \(productDetails.imageKey) \n \(error.localizedDescription)"
      }
    }
  }
}
