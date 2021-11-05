import SwiftUI
import Combine

public struct VerificationView: View {
  @ObservedObject var registration: Registration
  
  public var body: some View {
    VStack {
      Spacer()
      VStack {
        Spacer().frame(height: 40)
        VerificationCodeField(code: $registration.verificationCode)
        Text("Enter the verification code that is sent to you by text message.")
          .multilineTextAlignment(.center)
          .frame(width: 180, height: 40)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      Spacer()
    }
    .overlay(progressView)
    .navigationBarTitle("Enter Verification Code", displayMode: .inline)
    .alert($registration.alert)
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
          Text("Verifying...")
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
