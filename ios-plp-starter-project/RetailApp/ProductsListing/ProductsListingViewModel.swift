
import Foundation

protocol ProductsListingViewModel {
  var cellItems: Observable<[ProductViewModel]> { get }
  var errorMessage: Observable<String?> { get }
  var isLoading: Observable<Bool> { get }
  func loadProducts()
}

private struct ProductDetailsRequest: ProductRequest {
  let id: String
  let price: Price
  let name: String
}

final class ProductsListingViewModelImplementation: ProductsListingViewModel {
  // MARK: Public bindings
  var cellItems: Observable<[ProductViewModel]> = .init([]) {
    didSet {
      oldValue.value.forEach{ $0.didSelected.unbind(self) }
    }
  }
  var errorMessage: Observable<String?> = .init(nil)
  var isLoading: Observable<Bool> = .init(false)
  
  // MARK: Private dependecies
  private let service: ProductListingService
  private let offersService: OffersSerivce
  private let imageService: ImageService
  private let coordinator: RootCoordinator
  private let formatter: ProductFormatter
  private var cachedBadges: [String: UIImage] = [:]
  
  
  // MARK: Private variables
  private var groups: [String: DispatchGroup] = [:]
  
  // MARK: Init
  init(coordinator: RootCoordinator, productListingService: ProductListingService, offersService: OffersSerivce, imageService: ImageService, productFormatter: ProductFormatter) {
    self.coordinator = coordinator
    self.offersService = offersService
    self.imageService = imageService
    service = productListingService
    formatter = productFormatter
  }
  
  deinit {
    cellItems.value.forEach{ $0.didSelected.unbind(self) }
  }
  
  // MARK: Public functions
  func loadProducts() {
    isLoading.value = true
    errorMessage.value = nil
    cellItems.value = loadingCells()
    
    service.getProducts { [weak self] result in
      self?.isLoading.value = false
      self?.process(result: result)
    }
  }
  
  // MARK: Private functions
  private func process(result: Result<ProductsListing, Error>) {
    do {
      let listing = try result.unwrapped()
      // Operation of building view models can be heavy, and even blocking, ao better to run on BG async queue
      DispatchQueue.global(qos: .userInitiated).async {
        let viewModels = self.viewModels(for: listing)
        
        // Updating view models of UI binding had to be done on Main queue though
        DispatchQueue.main.async {
          self.cellItems.value = viewModels
        }
      }
      
    } catch {
      errorMessage.value = message(for: error)
    }
  }
  
  private func message(for error: Error) -> String {
    //TODO: return user-friendly error description
    return error.localizedDescription
  }
  
  private func group(for key: String) -> DispatchGroup {
    let group = groups[key] ?? DispatchGroup()
    groups[key] = group
    return group
  }
  
  /**
   Update badged at viewModel. Load the Image if needed.
   
   As there are very few badges for all products it makes sense to preloaded them all,
   But here is no need to load same badge twice.
   So I'm creating operation groups for each badge key.
   So If badge with that key already loading - wait for completion.
   */
  private func updateBadge(_ badge: OffersResponse.Badge, at productsViewModel: ProductViewModel) {
    let key = badge.name + "_icon"
    let group = self.group(for: key)
    // Waiting if other badges with same name currently loading
    group.wait()
    if let image = self.cachedBadges[key] {
      DispatchQueue.main.async {
        productsViewModel.badge.value = image
      }
      return
    }
    // Start badge loading (for key)
    group.enter()
    self.imageService.downloadImage(key: key) { [weak self] imageResponse in
      // Badge loading completed (for key)
      defer { group.leave() }
      guard let image = try? imageResponse.unwrapped() else { return }
      self?.cachedBadges[key] = image
      DispatchQueue.main.async {
        productsViewModel.badge.value = image
      }
    }
  }
  
  
  private func viewModels(for listing: ProductsListing) -> [ProductViewModel] {
    listing.products.map { product in
      
      // Create view model for specific product
      let productViewModel = self.formatter.viewModel(for: product)
      
      // Listen to product selection
      productViewModel.didSelected.bindNoFire(self) { [unowned self] _ in
        let request = ProductDetailsRequest(id: product.id, price: product.price, name: product.name)
        self.coordinator.presentDetails(for: request, thumbnail: productViewModel.image.value)
      }
      
      // Load and update badge, if needed
      self.offersService.badge(for: product.offerIds) { [weak self] badgeResponse in
        guard let badge = try? badgeResponse.unwrapped() else { return }
        self?.updateBadge(badge, at: productViewModel)
      }
      
      return productViewModel
    }
  }
  
  private func loadingCells() -> [ProductViewModel] {
    // TODO: return viewmodel for cells in loading state, some kind of skeleton cells for example
    return []
  }
  
}
