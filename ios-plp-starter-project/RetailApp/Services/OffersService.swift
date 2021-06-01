
import Foundation

extension OffersResponse {
  struct Badge {
    let name: String
    let type: String
  }
  
  var badges: [Badge] {
    
    availableBadges
      .components(separatedBy: "||")
      .flatMap { string -> [Badge] in
        let components = string.components(separatedBy: ":")
        
        guard components.count == 2 else { return [] }
        
        let name = components[0]
        let types = components[1].components(separatedBy: ",")
        let badges = types.enumerated().map {
          Badge(name: name, type: $0.element)
        }
        
        return badges
      }
  }
}

protocol OffersSerivce {
  
  func getOffers(for userid: String, completion: @escaping (Result<OffersResponse, Error>) -> Void)
  
  func offer(with id: String, completion: @escaping (Result<OffersResponse.Offer, Error>) -> Void)
  func badge(for offersIds: [String], completion: @escaping (Result<OffersResponse.Badge?, Error>) -> Void)
  
}

final class OfferServiceImplementation: OffersSerivce {
  
  enum ServiceError: Error {
    case pending
    case offerUnavaialble
  }
  
  private let api: API
  
  private var cachedOffers: Observable<OffersResponse?> = .init(nil)
  private var cachedBadgesImages: [String: UIImage] = [:]
  private var pending: Bool = false
  
  init(api: API) {
    self.api = api
  }
  
  deinit {
    self.cachedOffers.unbindAll()
  }
  
  func getOffers(for userId: String, completion: @escaping (Result<OffersResponse, Error>) -> Void) {
    guard pending == false else {
      completion(.error(ServiceError.pending))
      return
    }
    let resource = Resource<OffersResponse>(path: "api/user/\(userId)/offers")
    api.load(resource) { [weak self] in
      self?.pending = false
      self?.cachedOffers.value = try? $0.unwrapped()
      completion($0)
    }
  }
  
  func offer(with id: String, completion: @escaping (Result<OffersResponse.Offer, Error>) -> Void) {
    /**
     According to requirements:
     1. offers had to be requested only once, on launch time.
     2. products had to be requested/show in parallel
     
     As a result there is a race condition: products can  be received before offers.
     
     SLOUTION:
     1. request offers and save the to cache on response.
     2. observe cache:
     3. if offer with ID / badge requested after offers cached - return offer from cache, jump to 6
     4. if offer with ID / badge requested before while cahce is empty - wait
     5. when cache changed - return offer from cache
     6. when offer returned - remove observation
     */
    let observer = NSObject()
    cachedOffers.bind(observer) { [weak self] offersResponse in
      guard let offers = offersResponse?.offers, offers.count > 0 else { return }
      defer { self?.cachedOffers.unbind(observer) }
      
      if let offer = offers.first(where: { $0.id == id }) {
        completion(.value(offer))
      } else {
        completion(.error(ServiceError.offerUnavaialble))
      }
    }
  }
  
  func badge(for offersIds: [String], completion: @escaping (Result<OffersResponse.Badge?, Error>) -> Void) {
    let observer = NSObject()
    cachedOffers.bind(observer) { [weak self] offersResponse in
      guard  let offersResponse = offersResponse, offersResponse.offers.count > 0 else { return }
      defer { self?.cachedOffers.unbind(observer) }
      
      let matchingOffers = offersResponse.offers.filter { offersIds.contains ($0.id) }
      let matchingOfferTypes = matchingOffers.map { $0.type }
      let matchingBadges = offersResponse.badges.filter { matchingOfferTypes.contains($0.type) }
      
      completion(.value(matchingBadges.first))
    }
  }
  
}
