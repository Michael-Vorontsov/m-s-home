
import Foundation

struct ProductsListing: Codable {
  
  struct Product: Codable {
    let id: String
    let imageKey: String
    let name: String
    let offerIds: [String]
    let price: Price
  }
  
  let products: [Product]
}
