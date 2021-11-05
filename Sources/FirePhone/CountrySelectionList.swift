import SwiftUI

struct CountrySelectionList: View {
  @State private var searchTerm = ""
  var registration: Registration
  
  var body: some View {
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
  
  func countryRow(country: Country) -> some View {
    HStack {
      Text(country.flag)
        .width(20)
      Spacer().width(10)
      Text(country.name)
    }
  }
}

struct CountrySelectionList_Previews: PreviewProvider {
  static var previews: some View {
    CountrySelectionList(registration: Registration())
  }
}
