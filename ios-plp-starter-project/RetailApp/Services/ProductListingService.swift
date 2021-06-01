
import Foundation

protocol ProductListingService {
  func getProducts(completion: @escaping (Result<ProductsListing, Error>) -> Void)
}


class ProductListingServiceImplementation: ProductListingService {
  private let api: API

  init(api: API) {
    self.api = api
  }

  func getProducts(completion: @escaping (Result<ProductsListing, Error>) -> Void) {
    let resource = Resource<ProductsListing>(path: "api/products")
    api.load(resource, completion: completion)
  }
}
