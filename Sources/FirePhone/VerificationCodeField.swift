import SwiftUI

struct VerificationCodeField: View {
  @Binding var code: String
  
  var onSubmit: (()->())? = nil
  
  var body: some View {
    HStack {
      Spacer()
      TextField("------", text: $code)
//        .submitLabel(.done)
//        .onSubmit {
//          onSubmit?()
//        }
        .minimumScaleFactor(0.7)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .textContentType(.oneTimeCode)
        .padding()
        .keyboardType(.numberPad)
        .font(.system(size: 77, design: .monospaced))
        .width(340)
      Spacer()
    }
  }
}

struct VerificationCodeField_Previews: PreviewProvider {
  static var previews: some View {
    VerificationCodeField(code: .constant("123456"))
    VerificationCodeField(code: .constant(""))
  }
}
