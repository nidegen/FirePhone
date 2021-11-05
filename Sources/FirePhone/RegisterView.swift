import SwiftUI
import PhoneNumberKit

public struct RegisterView: View {
  @StateObject var registration = Registration()
  @State var showVerificationScreen = false

  public init() {}
  
  public var body: some View {
    if showVerificationScreen {
      VerificationView(registration: registration)
    } else {
    Form {
      Section() {
        Picker(selection: $registration.selectedCountry, label: Text("Your Country")) {
          CountrySelectionList(registration: registration)
        }
        HStack {
          Text(registration.selectedCountry.prefix)
          Divider()
          PhoneNumberField(placeHolder: "your phone number", phoneNumber: $registration.phoneNumber,
                           currentCountry: $registration.selectedCountry, validNumber: $registration.phoneNumberIsValid) {
            self.register()
          }
        }
        .font(.system(size: 32, weight: .light))
      }
    }
    .alert($registration.alert)
    .toolbar {
      trailingItems
    }
    .navigationBarTitle("Your Phone Number", displayMode: .inline)
    }
  }
  
  var trailingItems: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button("Continue") {
        register()
      }
      .disabled(!registration.phoneNumberIsValid)
    }
  }
  
  func register() {
    registration.register { result in
      if case .success = result {
        withAnimation {
          showVerificationScreen = true
        }
      }
    }
  }
}

struct RegisterView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      RegisterView()
    }
  }
}

extension View {
  func width(_ width: CGFloat) -> some View {
    self.frame(width: width)
  }
}
