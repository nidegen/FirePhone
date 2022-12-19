import Foundation
import Firebase
import PhoneNumberKit
import SwiftUI

class RegistrationViewModel: ObservableObject {
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
  
  @Published var didSubmitPhoneNumber = false
  
  @AppStorage("UserVerificationIdKey")
  var userVerificationId: String?
  
  init() {
    Auth.auth().useAppLanguage()
    
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
      Task {
        do {
          try await verify()
        } catch {
          self.verificationCode = ""
          self.isVerifying = false
          self.alertTitle = "Validation Code Error"
          self.alertMessage = error.localizedDescription
          
        }
      }
    }
  }
  
  var formattedNumber: String {
    (selectedCountry.prefix + self.phoneNumber).replacingOccurrences(of: " ", with: "")
  }
  
  private let echoUserVerificationIdKey = "EchoUserVerificationIdKey"
  // Should replace the current view states\
  
  @MainActor
  func register() async {
    if !phoneNumberIsValid {
      alertTitle = "Invalid Phone Number"
      alertMessage = "Please enter a valid phone number."
      return
    }
    
    withAnimation {
      didSubmitPhoneNumber = true
    }
    
    do {
      self.userVerificationId = try await PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil)
      self.didRegister = true
    } catch {
      self.alertTitle = "Error with \(PartialFormatter().formatPartial(self.formattedNumber))"
      self.alertMessage = error.localizedDescription
      self.didSubmitPhoneNumber = false
    }
  }
  
  func requestNumberChange(onSuccess: @escaping (String)->()) {
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: changeVerificationId ?? "", verificationCode: changeVerificationCode)
    
    
    Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
      if let error = error {
        self.alertTitle = "Number Change Error"
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
  
  func verify() async throws {
    guard let verificationID = self.userVerificationId else {
      throw FirePhoneError.missingUserVerificationId
    }
    self.isVerifying = true
    let credential = PhoneAuthProvider.provider().credential(
      withVerificationID: verificationID,
      verificationCode: verificationCode
    )
    
    try await Auth.auth().signIn(with: credential)
  }
  
  func registerPhoneNumber() {
    withAnimation {
      didSubmitPhoneNumber = true
    }

    Task {
      await register()
    }
  }
}
