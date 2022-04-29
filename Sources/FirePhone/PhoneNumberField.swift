import SwiftUI
import PhoneNumberKit

struct PhoneNumberField: UIViewRepresentable {
  @Binding var phoneNumber: String
  @Binding var currentCountry: Country
  @Binding var validNumber: Bool

  private let textField = PhoneNumberTextField()
  
  var returnAction: (()->())?

  func makeUIView(context: Context) -> PhoneNumberTextField {
    textField.withPrefix = false

    textField.font = UIFont.systemFont(ofSize: 29, weight: .light)
    
    
    return textField
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func updateUIView(_ view: PhoneNumberTextField, context: Context) {
//    DispatchQueue.main.async {
//      if self.phoneNumber != view.text {
//        self.phoneNumber = view.text ?? ""
//      }
//    }
    view.partialFormatter.defaultRegion = currentCountry.regionCode
  }
  
  final class Coordinator: NSObject, UITextFieldDelegate {
    
    var parent: PhoneNumberField

    init(_ field: PhoneNumberField) {
      self.parent = field
      super.init()
      field.textField.addTarget(self, action: #selector(editChanged), for: .editingChanged)
      field.textField.textContentType = .telephoneNumber
      field.textField.returnKeyType = .done
      field.textField.addTarget(self, action: #selector(doneButtonTapped), for: .editingDidEndOnExit)
      field.textField.delegate = self
    }
    
    // Default actions:
    @objc func doneButtonTapped() {
      self.parent.textField.resignFirstResponder()
      self.parent.returnAction?()
    }
      
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      /// Updates the current country if a number wiht country code is entered, especially when pasting
      if string.hasPrefix("+"),
         let phonenumber = try? parent.textField.phoneNumberKit.parse(string),
          let regionCode = parent.textField.phoneNumberKit.getRegionCode(of: phonenumber),
         regionCode != self.parent.currentCountry.regionCode {
        parent.textField.partialFormatter.defaultRegion = regionCode
        self.parent.currentCountry = Country(regionCode: regionCode, phoneNumberKit: self.parent.textField.phoneNumberKit)
      }
      
      return true
    }
        
    @objc func editChanged() {
      /// Updates the registration model number when text changed
      DispatchQueue.main.async {
        if self.parent.validNumber != self.parent.textField.isValidNumber {
          self.parent.validNumber = self.parent.textField.isValidNumber
        }
        self.parent.phoneNumber = self.parent.textField.text ?? ""
      }
    }
  }
}

extension String {
  func deletingPrefix(_ prefix: String) -> String {
    guard self.hasPrefix(prefix) else { return self }
    return String(self.dropFirst(prefix.count))
  }
}

struct PhoneNumberField_Previews: PreviewProvider {
  static var previews: some View {
    PhoneNumberField(phoneNumber: .constant("023"), currentCountry: .constant(.ch), validNumber: .constant(true))
  }
}
