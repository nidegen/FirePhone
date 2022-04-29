import PhoneNumberKit

extension PhoneNumberTextField {
  var textCountryCode: UInt64? {
    if let number = self.text,
       let phonenumber = try? self.phoneNumberKit.parse(number) {
      return phonenumber.countryCode
    }
    return nil
  }
}
