import SwiftUI

struct VerificationCodeField: View {
  @Binding var code: String
  
  var onSubmit: (()->())? = nil
  
  var body: some View {
    HStack {
      Spacer()
      textField
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
  
  @ViewBuilder
  var textField: some View {
    if #available(iOS 15.0, *) {
      TextField("------", text: $code)
        .submitLabel(.done)
        .onSubmit {
          onSubmit?()
        }
    } else {
      TextField("------", text: $code)
    }
  }
}

struct VerificationCodeField_Previews: PreviewProvider {
  static var previews: some View {
    VerificationCodeField(code: .constant("123456"))
    VerificationCodeField(code: .constant(""))
  }
}
