
import UIKit

protocol RootCoordinator {
  func presentProductsListing()
  func presentDetails(for request: ProductRequest, thumbnail: UIImage?)
}

final class RootCoordinatorImplementation: RootCoordinator {
  
  // MARK: Private dependencies
  private var window: UIWindow
  private let baseUrl: URL
  
  // User "4"  contains offers with different badges.
  private let userId: String = "4"
  
  // MARK: Init
  init(window: UIWindow, url: URL) {
    self.window = window
    baseUrl = url
    setup()
  }
  
  private func setup() {
    offersService.getOffers(for: userId) { _ in
      // TODO: process error
    }
    window.rootViewController = navigationController
  }
  
  // MARK: Public navigation
  func presentProductsListing() {
    if navigationController.viewControllers.count == 0 {
      navigationController.setViewControllers([listingsController], animated: false)
      return
    }
    
    if navigationController.viewControllers.contains(listingsController) {
      navigationController.popToViewController(listingsController, animated: true)
      return
    }
    
    self.navigationController.pushViewController(listingsController, animated: true)
  }
  
  func presentDetails(for request: ProductRequest, thumbnail: UIImage?) {

    /**
     For some reason ImageService cannot fetch images for ProductDetails keys.
     So I'm passing thumbnail as additional argument
     */

    let viewModel = ProductDetailsViewModel(
      productRequest: request,
      listingImage: thumbnail,
      productDetailsService: productDetailsService,
      imageService: imageService
    )
    
    let viewController = ProductDetailsViewController(viewModel: viewModel)
    
    navigationController.pushViewController(viewController, animated: true)
  }
  
  // MARK: Subscreens
  private lazy var navigationController: UINavigationController = {
    UINavigationController()
  }()
  
  private lazy var listingsController: UIViewController = {
    let controller = ProductsListingViewController()
    let viewModel = ProductsListingViewModelImplementation(
      coordinator: self,
      productListingService: productListingService,
      offersService: offersService,
      imageService: imageService,
      productFormatter: productFormatter
    )
    controller.viewModel = viewModel
    return controller
  }()
  
  // MARK: Formatters
  private lazy var productFormatter: ProductFormatter = {
    ProductFormatterImplementation(imageService: imageService, priceFormatter: priceFormatter)
  }()
  
  private lazy var priceFormatter: PriceFormatter = {
    PriceFormatterImplementation(discountedPriceColor: .red, priceColor: .black)
  }()
  
  // MARK: Services
  
  private lazy var api: API = {
    return API(
      urlSession: URLSession.shared,
      baseURL: baseUrl
    )
  }()
  
  private lazy var offersService: OffersSerivce = {
    OfferServiceImplementation(api: api)
  }()
  
  private lazy var productListingService: ProductListingService = {
    ProductListingServiceImplementation(api: api)
  }()
  
  private lazy var imageService: ImageService = {
    ImageServiceImplementation(api: api)
  }()
  
  private lazy var productDetailsService = {
    ProductDetailsServiceImplementation(api: api)
  }()
  
}
