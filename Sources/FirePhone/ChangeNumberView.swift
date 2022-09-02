import SwiftUI
import Firebase

public struct ChangeNumberView: View {
  @StateObject var changer = Registration()
  
  public init(onSuccess: @escaping (String)->()) {
    self.onSuccess = onSuccess
  }
  
  var onSuccess: (String)->()
  
  public var body: some View {
    if changer.changeVerificationId != nil {
      VStack {
        Spacer()
        VerificationCodeField(code: $changer.changeVerificationCode)
        Button("System_Change") {
          changer.requestNumberChange(onSuccess: onSuccess)
        }
        Spacer()
      }
      .alert(item: $changer.alertMessage) { message in
        Alert(title: Text(changer.alertTitle), message: Text(message), dismissButton: .default(Text("System_OK")))
      }
    } else {
      Form {
        Section(footer: Text("Auth_ChangeNumber_EnterNewNumberExplanation")) {
          Picker(selection: $changer.selectedCountry, label: Text("Auth_YourCountry")) {
            CountrySelectionList(registration: changer)
          }
          HStack {
            Text(changer.selectedCountry.prefix)
            Divider()
            #if canImport(UIKit)
            PhoneNumberField(phoneNumber: $changer.phoneNumber,
                             currentCountry: $changer.selectedCountry,
                             validNumber: $changer.phoneNumberIsValid) {
              changer.checkNewNumber()
            }
            #endif
          }
          .font(.system(size: 32, weight: .light))
        }
      }
      .alert(item: $changer.alertMessage) { message in
        Alert(title: Text(changer.alertTitle), message: Text(message), dismissButton: .default(Text("System_OK")))
      }
    }
  }
}

extension String: Identifiable {
  public var id: String {
    self
  }
}

struct ChangeNumberView_Previews: PreviewProvider {
  static var previews: some View {
    ChangeNumberView { newNumber in
      print("successuflly changed to \(newNumber)")
    }
  }
}
