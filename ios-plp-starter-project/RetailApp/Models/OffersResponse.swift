
import Foundation

struct OffersResponse: Codable {
  struct Offer: Codable {
    let id: String
    let type: String
    let title: String
  }

  let offers: [Offer]
  let availableBadges: String
}
