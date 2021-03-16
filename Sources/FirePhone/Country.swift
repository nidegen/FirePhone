//
//  Country.swift
//  Echo
//
//  Created by Nicolas Degen on 17.08.20.
//  Copyright © 2020 Echo Labs AG. All rights reserved.
//

import Foundation

import PhoneNumberKit

struct Country: Identifiable, Hashable {
  static var ch = Country()
  
  var id: String {
    return code
  }
  
  var name: String
  var code: String
  var prefix: String
  
  private init() {
    self.code = "CH"
    self.name = Locale.current.localizedString(forRegionCode: "CH") ?? "Unknown"
    self.prefix = "+41"
  }
  
  init(countryCode: String, phoneNumberKit: PhoneNumberKit) {
    self.name = Locale.current.localizedString(forRegionCode: countryCode) ?? "Unknown"
    self.code = countryCode
    self.prefix = "+\(phoneNumberKit.countryCode(for: countryCode) ?? 1)"
  }
  
  var flag: String {
    let base : UInt32 = 127397
    var s = ""
    for v in code.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
}
