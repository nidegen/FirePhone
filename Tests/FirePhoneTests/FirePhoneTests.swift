import XCTest
import PhoneNumberKit
@testable import FirePhone

final class FirePhoneTests: XCTestCase {
  let phoneNumberKit = PhoneNumberKit()

  func testCountryExtraction() {
    guard let abab = try? phoneNumberKit.parse("+49 170 1234567 ") else { XCTFail(); return }
    print(abab.countryCode)
    do {
      let b = try phoneNumberKit.parse("0049170 1234567")
      print(b.countryCode)
      print(phoneNumberKit.getRegionCode(of: b))
    } catch {
      print(error.localizedDescription)
    }
    XCTAssert(true)
  }
}
