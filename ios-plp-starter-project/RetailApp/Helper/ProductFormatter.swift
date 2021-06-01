
import Foundation

protocol ProductFormatter {
  func viewModel(for product: ProductsListing.Product) -> ProductViewModel
}

final class ProductFormatterImplementation: ProductFormatter {
  let service: ImageService
  let formatter: PriceFormatter

  init(imageService: ImageService, priceFormatter: PriceFormatter) {
    service = imageService
    formatter = priceFormatter
  }

  func viewModel(for product: ProductsListing.Product) -> ProductViewModel {
    ProductViewModelImplementation(
      name: product.name,
      imageKey: product.imageKey,
      price: product.price,
      imageService: service,
      priceFormatter: formatter
    )
  }
}
