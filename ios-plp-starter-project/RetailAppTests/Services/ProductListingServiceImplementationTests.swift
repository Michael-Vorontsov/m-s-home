
@testable import RetailApp
import XCTest

class ProductListingServiceImplementationTests: XCTestCase {
  
  struct TestError: Error {
    let localisedError: String
  }
  
  
  override func setUpWithError() throws {
  }
  
  func testListingReturnedOnRequestFromProdAPI() throws {
    // Given
    let url = URL(string: "http://interview-tech-testing.herokuapp.com")!
    let service = ProductListingServiceImplementation(api: API(urlSession: URLSession.shared, baseURL: url))
    var spyResult: Result<ProductsListing, Error>?
    let exp = expectation(description: "Result")
    // When
    
    service.getProducts { result in
      spyResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 10.0)
    
    // Then
    guard let fetchedResult = spyResult else {
      throw TestError(localisedError: "Unable to unwrap spy results!")
    }
    
    let listings = try fetchedResult.unwrapped()
    XCTAssertEqual(listings.products.count, 96)
  }
  
  func testListingReturnedOnRequestFromStubSession() throws {
    // Given
    let url = URL(string: "http://interview-tech-testing.herokuapp.com")!
    let stubSession = MockURLSessionProtocol()
    let service = ProductListingServiceImplementation(api: API(urlSession: stubSession, baseURL: url))
    var spyResult: Result<ProductsListing, Error>?
    let exp = expectation(description: "Result")
    let stubDataURL = Bundle(for: Self.self).url(forResource: "Products", withExtension: "json")!
    let stubData = try! Data(contentsOf: stubDataURL)
    
    // When
    service.getProducts { result in
      spyResult = result
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(
      stubData,
      HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
      nil
    )
    
    wait(for: [exp], timeout: 0.1)
    
    // Then
    guard let fetchedResult = spyResult else {
      throw TestError(localisedError: "Unable to unwrap spy results!")
    }
    
    let listings = try fetchedResult.unwrapped()
    XCTAssertEqual(listings.products.count, 96)
  }
  
}
