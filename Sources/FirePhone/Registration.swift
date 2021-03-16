import Foundation
import Firebase
import PhoneNumberKit

class Registration: ObservableObject {
  @Published var phoneNumber = ""
  @Published var phoneNumberIsValid = false
  @Published var selectedCountry: Country
  @Published var didRegister = false
  @Published var alert: AlertData?
  
  @Published var verificationCode = "" {
    didSet {
      verifyCode()
    }
  }
  
  private var didSendVerification = false
  private let defaultCode = PhoneNumberKit.defaultRegionCode()
  let countries: [Country]
  
  let phoneNumberKit = PhoneNumberKit {
    guard let jsonPath = Bundle.main.path(forResource: "PhoneNumberMetadata", ofType: "json") else {
      throw PhoneNumberError.metadataNotFound
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
    return data
  }
  
  func verifyCode() {
    let filtered = verificationCode.filter { "0123456789".contains($0) }
    if filtered != verificationCode {
      verificationCode = filtered
    }
    if self.verificationCode.count == 6 && !didSendVerification {
      self.alert = AlertData(title: "Verifying..", message: "Checking your code.")
      
      self.verify { success in
        if success {
          
        }
        self.alert = nil
      }
    }
  }
  
  var formattedNumber: String {
    (selectedCountry.prefix + self.phoneNumber).replacingOccurrences(of: " ", with: "")
  }
  
  init() {
    var allCodes = phoneNumberKit.allCountries()
    allCodes = allCodes.filter { return $0 != "001" }.sorted {
      let a = Locale.current.localizedString(forRegionCode: $0)?.folding(options: .diacriticInsensitive, locale: nil) ?? ""
      let b = Locale.current.localizedString(forRegionCode: $1)?.folding(options: .diacriticInsensitive, locale: nil) ?? ""
      return a < b
    }
    var tmp = [Country]()
    tmp.reserveCapacity(allCodes.count)
    
    for countryCode in allCodes {
      tmp.append(Country(countryCode: countryCode,  phoneNumberKit: phoneNumberKit))
    }
    
    countries = tmp
    
    selectedCountry = Country(countryCode: defaultCode, phoneNumberKit: phoneNumberKit)
  }
  
  private let echoUserVerificationIdKey = "EchoUserVerificationIdKey"
  // Should replace the current view states\
  
  func register(completion: @escaping (Result<Void, Error>)->()) {
    Auth.auth().languageCode = Locale.current.languageCode
    
    PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil) { (verificationID, error) in
      if let error = error {
        print(error.localizedDescription)
        completion(.failure(error))
      } else {
        completion(.success(()))
        UserDefaults.standard.set(verificationID, forKey: self.echoUserVerificationIdKey)
      }
    }
  }
  
  func verify(completion: @escaping ((Bool) -> ())) {
    guard let verificationID = UserDefaults.standard.string(forKey: echoUserVerificationIdKey) else {
      completion(false)
      return
    }
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                             verificationCode: verificationCode)
    
    Auth.auth().signIn(with: credential) { (authResult, error) in
      if error != nil {
        self.verificationCode = ""
        self.alert = AlertData(title: "Error: Incorrect code", message: "Please try again")
      }
      completion(error == nil)
    }
  }
}
