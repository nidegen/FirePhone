//
import SwiftUI
import Combine

public struct VerificationView: View {
  @ObservedObject var registration: Registration
  
  public var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        TextField("123456", text: $registration.verificationCode)
          .minimumScaleFactor(0.7)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .textContentType(.oneTimeCode)
          .padding()
          .keyboardType(.numberPad)
          .font(.system(size: 77, design: .monospaced))
          .width(340)
        Spacer()
      }
      Spacer()
    }
    .alert($registration.alert)
    .onDisappear {
      registration.alert = nil
    }
    .navigationBarTitle("Enter Verification Code", displayMode: .inline)
    .alert($registration.alert)
  }
}


struct VerificationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      VerificationView(registration: Registration())
    }
  }
}
