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
          NavigationLink {
            CountrySelectionList(registration: registration)
          } label: {
            HStack {
              Text("Auth_YourCountry")
              Spacer()
              HStack {
                Text(registration.selectedCountry.flag)
                  .width(20)
                Spacer().width(10)
                Text(registration.selectedCountry.name)
              }
            }
          }
          HStack {
            Text(registration.selectedCountry.prefix)
            Divider()
            #if canImport(UIKit)
            PhoneNumberField(
              phoneNumber: $registration.phoneNumber,
              currentCountry: $registration.selectedCountry,
              validNumber: $registration.phoneNumberIsValid
            ) {
              self.register()
            }
            #else
            TextField("Phone", text: $registration.phoneNumber)
            #endif
          }
          .font(.system(size: 32, weight: .light))
        }
      }
      .alert(item: $registration.alertMessage) { message in
        Alert(title: Text(registration.alertTitle), message: Text(message), dismissButton: .default(Text("System_OK")))
      }
      .toolbar {
        trailingItems
      }
      #if canImport(UIKit)
      .navigationBarTitle("Auth_YourPhoneNumber", displayMode: .inline)
      #endif
    }
  }
  
  var trailingItems: some ToolbarContent {
#if canImport(UIKit)
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button("System_Continue") {
        register()
      }
      .disabled(!registration.phoneNumberIsValid)
    }
    #else
    ToolbarItemGroup(placement: .navigation) {
      Button("System_Continue") {
        register()
      }
      .disabled(!registration.phoneNumberIsValid)
    }
    #endif
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
