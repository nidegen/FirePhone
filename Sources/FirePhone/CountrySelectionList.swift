import SwiftUI

struct CountrySelectionList: View {
  @Environment(\.presentationMode) var presentation
  @State private var searchTerm = ""
  var registration: RegistrationViewModel
  
  var filteredCountries: [Country] {
    registration.countries.filter {
      searchTerm.isEmpty ? true : $0.name.contains(searchTerm)
    }
  }
  
  var body: some View {
    List {
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(Color(UIColor.secondaryLabel))
        TextField("System_Search", text: $searchTerm)
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
      ForEach(filteredCountries) {
        countryRow(country: $0)
      }
    }
  }
  
  func countryRow(country: Country) -> some View {
    Button {
      registration.selectedCountry = country
      presentation.wrappedValue.dismiss()
    } label: {
      HStack {
        Text(country.flag)
          .width(20)
        Spacer().width(10)
        Text(country.name)
        if country == registration.selectedCountry {
          Spacer()
          Image(systemName: "checkmark")
        }
      }
    }
    .buttonStyle(.plain)
  }
}

struct CountrySelectionList_Previews: PreviewProvider {
  static var previews: some View {
    CountrySelectionList(registration: RegistrationViewModel())
  }
}
