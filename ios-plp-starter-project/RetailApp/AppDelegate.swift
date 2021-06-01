import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  lazy var coordinator: RootCoordinator = {
    RootCoordinatorImplementation(
      window: window!,
      url: URL(string: "http://interview-tech-testing.herokuapp.com")!
    )
  }()
  
  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.makeKeyAndVisible()
    coordinator.presentProductsListing()
    
    return true
  }
}
