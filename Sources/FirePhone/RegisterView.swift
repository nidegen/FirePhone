import SwiftUI
import PhoneNumberKit

public struct RegisterView: View {
  @StateObject var registration = Registration()
  @State private var searchTerm = ""
  
  func countryRow(country: Country) -> some View {
    HStack {
      Text(country.flag)
        .width(20)
      Spacer().width(10)
      Text(country.name)
    }
  }
  
  public init() {}
  
  public var body: some View {
    Form {
      Section() {
        Picker(selection: $registration.selectedCountry, label: Text("Your Country")) {
          List {
            HStack {
              Image(systemName: "magnifyingglass")
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.leading, 16)
              TextField("Search", text: $searchTerm)
              Spacer()
              if searchTerm != "" {
                Button(action: {
                  withAnimation {
                    searchTerm = ""
                  }
                }, label: {
                  Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                })
              }
            }
            ForEach(registration.countries.filter({ searchTerm.isEmpty ? true : $0.name.contains(searchTerm) }), id: \.self) {
              countryRow(country: $0)
            }
          }
        }
        HStack {
          Text(registration.selectedCountry.prefix)
          Divider()
          PhoneNumberField(placeHolder: "your phone number", phoneNumber: $registration.phoneNumber,
                           currentCountry: $registration.selectedCountry, validNumber: $registration.phoneNumberIsValid) {
            continueAction()
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
  
  func continueAction() {
    if registration.phoneNumberIsValid {
      registration.register { result in
        switch result {
        case .failure(let error):
          registration.alert = AlertData(title: "Error with \(PartialFormatter().formatPartial(registration.formattedNumber))", message: error.localizedDescription)
        case .success():
          registration.didRegister = true
        }
      }
    }
  }
  
  var trailingItems: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button("Continue") {
        continueAction()
      }
      .disabled(!registration.phoneNumberIsValid)
      NavigationLink(destination: VerificationView(registration: registration), isActive: $registration.didRegister) {
        EmptyView()
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
