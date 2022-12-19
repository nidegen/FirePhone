import SwiftUI
import PhoneNumberKit

public struct RegisterView: View {
  @StateObject var registration = RegistrationViewModel()
  
  public init() {}
  
  public var body: some View {
    if registration.didRegister {
      VerificationView(registration: registration)
    } else if registration.didSubmitPhoneNumber {
      ProgressView()
        .ignoresSafeArea(.keyboard)
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
            
            PhoneNumberField(
              phoneNumber: $registration.phoneNumber,
              currentCountry: $registration.selectedCountry,
              validNumber: $registration.phoneNumberIsValid
            ) {
              registration.registerPhoneNumber()
            }
          }
          .font(.system(size: 32, weight: .light))
        }
      }
      .alert(item: $registration.alertMessage) { message in
        Alert(
          title: Text(registration.alertTitle),
          message: Text(message),
          dismissButton: .default(Text("System_OK"))
        )
      }
      .toolbar {
        trailingItems
      }
      .navigationBarTitle("Auth_YourPhoneNumber", displayMode: .inline)
    }
  }
  
  var trailingItems: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button("System_Continue") {
        registration.registerPhoneNumber()
      }
      .disabled(!registration.phoneNumberIsValid)
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
