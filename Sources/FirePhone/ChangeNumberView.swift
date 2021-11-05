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
        Button("Change") {
          changer.requestNumberChange(onSuccess: onSuccess)
        }
        Spacer()
      }
      .alert($changer.alert)
    } else {
      Form {
        Section(footer: Text("Enter the new phone number that you want to use. Be aware that you cannot undo this.")) {
          Picker(selection: $changer.selectedCountry, label: Text("Your Country")) {
            CountrySelectionList(registration: changer)
          }
          HStack {
            Text(changer.selectedCountry.prefix)
            Divider()
            PhoneNumberField(placeHolder: "your phone number", phoneNumber: $changer.phoneNumber,
                             currentCountry: $changer.selectedCountry, validNumber: $changer.phoneNumberIsValid) {
              changer.checkNewNumber()
            }
          }
          .font(.system(size: 32, weight: .light))
        }
      }
      .alert($changer.alert)
    }
  }
}

struct ChangeNumberView_Previews: PreviewProvider {
  static var previews: some View {
    ChangeNumberView { newNumber in
      print("successuflly changed to \(newNumber)")
    }
  }
}
