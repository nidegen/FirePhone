import Foundation
import Firebase
import PhoneNumberKit
import SwiftUI

class Registration: ObservableObject {
  @Published var phoneNumber = ""
  @Published var phoneNumberIsValid = false
  @Published var selectedCountry: Country
  @Published var didRegister = false
  @Published var alertMessage: String?
  @Published var alertTitle = "Error"
  @Published var isVerifying = false
  
  @Published var verificationCode = "" {
    didSet {
      verifyCode()
    }
  }
  
  @Published var changeVerificationId: String?
  @Published var changeVerificationCode = ""
  
  
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
      tmp.append(Country(regionCode: countryCode,  phoneNumberKit: phoneNumberKit))
    }
    
    countries = tmp
    
    selectedCountry = Country(regionCode: defaultCode, phoneNumberKit: phoneNumberKit)
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
      self.verify { success in
        if success {
          
        }
      }
    }
  }
  
  var formattedNumber: String {
    (selectedCountry.prefix + self.phoneNumber).replacingOccurrences(of: " ", with: "")
  }
  
  private let echoUserVerificationIdKey = "EchoUserVerificationIdKey"
  // Should replace the current view states\
  
  func register(completion: ((Result<Void, Error>)->())? = nil) {
    
    if !phoneNumberIsValid {
      alertTitle = "Invalid Phone Number"
      alertMessage = "Please enter a valid phone number."
      return
    }
    Auth.auth().languageCode = Locale.current.languageCode
    
    PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil) { (verificationID, error) in
      if let error = error {
        self.alertTitle = "Error with \(PartialFormatter().formatPartial(self.formattedNumber))"
        self.alertMessage = error.localizedDescription
        completion?(.failure(error))
      } else {
        completion?(.success(()))
        self.didRegister = true
        UserDefaults.standard.set(verificationID, forKey: self.echoUserVerificationIdKey)
      }
    }
  }
  
  func requestNumberChange(onSuccess: @escaping (String)->()) {
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: changeVerificationId ?? "", verificationCode: changeVerificationCode)
    
    Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
      if let error = error {
        self.alertTitle = "Verification Error"
        self.alertMessage = error.localizedDescription
      } else {
        onSuccess(self.formattedNumber)
      }
    })
  }
  
  func checkNewNumber() {
    if !phoneNumberIsValid {
      self.alertTitle = "Invalid Phone Number"
      self.alertMessage = "Please enter a valid phone number."
      return
    }
    
    PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil) { (verificationID, error) in
      
      if let error = error {
        self.alertTitle = "Phone Number Error"
        self.alertMessage = error.localizedDescription
        return
      }
      
      withAnimation {
        self.changeVerificationId = verificationID
      }
    }
  }
  
  func verify(completion: @escaping ((Bool) -> ())) {
    guard let verificationID = UserDefaults.standard.string(forKey: echoUserVerificationIdKey) else {
      completion(false)
      return
    }
    self.isVerifying = true
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                             verificationCode: verificationCode)
    
    Auth.auth().signIn(with: credential) { (authResult, error) in
      if error != nil {
        self.verificationCode = ""
        self.isVerifying = false
      }
      completion(error == nil)
    }
  }
}
