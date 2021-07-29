import Foundation
import PhoneNumberKit

struct Country: Identifiable, Hashable {
  static var ch = Country()
  
  var id: String {
    return regionCode
  }
  
  var name: String
  var regionCode: String
  var prefix: String
  
  init(regionCode: String = Locale.current.regionCode ?? "CH", phoneNumberKit: PhoneNumberKit = PhoneNumberKit() ) {
    self.name = Locale.current.localizedString(forRegionCode: regionCode) ?? "Unknown"
    self.regionCode = regionCode
    self.prefix = "+\(phoneNumberKit.countryCode(for: regionCode) ?? 41)"
  }
  
  var flag: String {
    let base : UInt32 = 127397
    var s = ""
    for v in regionCode.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
}
