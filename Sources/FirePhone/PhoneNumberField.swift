import SwiftUI
import PhoneNumberKit

struct PhoneNumberField: UIViewRepresentable {
  var placeHolder: String
  
  @Binding var phoneNumber: String
  @Binding var currentCountry: Country
  @Binding var validNumber: Bool

  private let textField = PhoneNumberTextField()

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
    view.partialFormatter.defaultRegion = currentCountry.code
  }
  
  final class Coordinator: NSObject, UITextFieldDelegate {
    
    var parent: PhoneNumberField

    init(_ field: PhoneNumberField) {
      self.parent = field
      super.init()
      field.textField.addTarget(self, action: #selector(editChanged), for: .editingChanged)
      field.textField.textContentType = .telephoneNumber
    }
    
    @objc func editChanged() {
      self.parent.textField.text = self.parent.textField.text?.deletingPrefix(self.parent.currentCountry.prefix)
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
    PhoneNumberField(placeHolder: "Number", phoneNumber: .constant("023"), currentCountry: .constant(.ch), validNumber: .constant(true))
  }
}
