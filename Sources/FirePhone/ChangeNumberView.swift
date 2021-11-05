import SwiftUI
import Firebase

public struct ChangeNumberView: View {
  @State var verificationId: String?
  @State var phoneNumber = ""
  @State var verificationCode = ""
  @State var alert: AlertData?
  
  public init(onSuccess: @escaping (String)->()) {
    self.onSuccess = onSuccess
  }
  
  
  var onSuccess: (String)->()
  
  public var body: some View {
    if let verificationId = verificationId {
      VStack {
        Spacer()
        VerificationCodeField(code: $verificationCode)
        Button("Change") {
          
          let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
          
          Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
            if let error = error {
              self.alert = AlertData(title: "Verification Error", message: error.localizedDescription)
            } else {
              onSuccess(phoneNumber)
            }
          })
        }
        Spacer()
      }
      .alert($alert)
    } else {
      Form {
        TextField("Phone Number", text: $phoneNumber)
        Button("Submit") {
          PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            
            if let error = error {
              self.alert = AlertData(title: "Phone Number Error", message: error.localizedDescription)
              return
            }
            
            self.verificationId = verificationID
          }
        }
      }
      .alert($alert)
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
