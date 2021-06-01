
@testable import RetailApp
import XCTest

class OfferServiceImplementationTests: XCTestCase {

  var service: OfferServiceImplementation!
  var stubResponse: (Data?, URLResponse?, Error?)!
  var stubSession: MockURLSessionProtocol!

  override func setUpWithError() throws {

    let stubDataURL = Bundle(for: Self.self).url(forResource: "Offers", withExtension: "json")!
    let stubData = try! Data(contentsOf: stubDataURL)
    stubSession = MockURLSessionProtocol()
    let url = URL(string: "http://interview-tech-testing.herokuapp.com")!
    let api = API(urlSession: stubSession, baseURL: url)
    let stubHttpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

    stubResponse = (stubData, stubHttpResponse, nil)

    service = OfferServiceImplementation(api: api)
  }

  func testGetOffersToProductionApiCallReturnsOffers() throws {
    // Given
    var spyResult: Result<OffersResponse, Error>?
    let exp = expectation(description: "Result")
    // When

    service.getOffers(for: "1") { result in
      spyResult = result
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offersResponse = try spyResult?.unwrapped()
    XCTAssertEqual(offersResponse?.offers.count, 3)
  }

  func testGetOffersToProductionApiCallReturnsBadges() throws {
    // Given
    var spyResult: Result<OffersResponse, Error>?
    let exp = expectation(description: "Result")
    // When

    service.getOffers(for: "1") { result in
      spyResult = result
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offersResponse = try spyResult?.unwrapped()
    XCTAssertEqual(offersResponse?.badges.count, 4)
  }

  func testGetOfferForIdReturnsOffer() throws {
    // Given
    var spyResult: Result<OffersResponse.Offer, Error>?
    let exp = expectation(description: "Result")
    service.getOffers(for: "1") { _ in }
    // When
    service.offer(with: "1") {
      spyResult = $0
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offerResponse = try spyResult?.unwrapped()
    XCTAssertEqual(offerResponse?.title, "Get it while it lasts!")
    XCTAssertEqual(offerResponse?.type, "REDUCED")
  }

  func testGetBadgeForSingleOfferIdReturnsBadge() throws {
    // Given
    var spyResult: Result<OffersResponse.Badge?, Error>?
    let exp = expectation(description: "Result")
    service.getOffers(for: "1") { _ in }
    // When
    service.badge(for: ["1"]) {
      spyResult = $0
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offerResponse = try spyResult?.unwrapped()
    XCTAssertEqual(offerResponse?.type, "REDUCED")
    XCTAssertEqual(offerResponse?.name, "gonesoon")
  }

  func testGetBadgeForSingleOfferIdReturnsBadgeWhenOffersRequestedAfter() throws {
    // Given
    var spyResult: Result<OffersResponse.Badge?, Error>?
    let exp = expectation(description: "Result")
    service.badge(for: ["1"]) {
      spyResult = $0
      exp.fulfill()
    }

    // When
    service.getOffers(for: "1") { _ in }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offerResponse = try spyResult?.unwrapped()
    XCTAssertNotNil(offerResponse?.type, "REDUCED")
    XCTAssertEqual(offerResponse?.name, "gonesoon")
  }

  func testGetBadgeForMultipleOfferIdReturnsBadge() throws {
    // Given
    var spyResult: Result<OffersResponse.Badge?, Error>?
    let exp = expectation(description: "Result")
    service.getOffers(for: "1") { _ in }
    // When
    service.badge(for: ["1", "2", "3"]) {
      spyResult = $0
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offerResponse = try spyResult?.unwrapped()
    XCTAssertEqual(offerResponse?.type, "REDUCED")
    XCTAssertEqual(offerResponse?.name, "gonesoon")
  }

  func testGetBadgeForSingleOfferWithoutAbadgeReturnsNoBadge() throws {
    // Given
    var spyResult: Result<OffersResponse.Badge?, Error>?
    let exp = expectation(description: "Result")
    service.getOffers(for: "1") { _ in }
    // When
    service.badge(for: ["10"]) {
      spyResult = $0
      exp.fulfill()
    }
    stubSession.lastCompletionHandler?(stubResponse.0, stubResponse.1, stubResponse.2)
    wait(for: [exp], timeout: 0.1)

    // Then
    let offerResponse = try spyResult?.unwrapped()
    XCTAssertNil(offerResponse)
  }
}
