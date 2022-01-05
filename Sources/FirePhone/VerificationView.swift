import SwiftUI
import Combine

public struct VerificationView: View {
  @ObservedObject var registration: Registration
  
  public var body: some View {
    VStack {
      Spacer()
      VStack {
        Spacer().frame(height: 40)
        VerificationCodeField(code: $registration.verificationCode) {
          registration.verifyCode()
        }
        Text("Auth_EnterCodeExpl")
          .multilineTextAlignment(.center)
          .frame(width: 180, height: 40)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      Spacer()
    }
    .overlay(progressView)
    .navigationBarTitle("Auth_EnterCode", displayMode: .inline)
    .alert(item: $registration.alertMessage) { message in
      Alert(title: Text(registration.alertTitle), message: Text(message), dismissButton: .default(Text("System_OK")))
    }
  }
  
  @ViewBuilder
  var progressView: some View {
    if registration.isVerifying {
      ZStack {
        Color(UIColor.systemBackground)
          .clipShape(RoundedRectangle(cornerRadius: 5))
        VStack {
          ProgressView()
            .padding()
          (Text("Auth_Verifying") + Text("..."))
            .font(.footnote)
        }
        .padding()
      }
      .ignoresSafeArea()
    }
  }
}


struct VerificationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      VerificationView(registration: Registration())
    }
  }
}
