import SwiftUI
#if canImport(UIKit)
struct VerificationCodeField: UIViewRepresentable {
  
  @Binding var code: String
  var onSubmit: (()->())? = nil
  var becomesFirstResponder = true
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField()
    textField.delegate = context.coordinator
    
    textField.font = UIFont.monospacedSystemFont(ofSize: 77, weight: .regular)
    textField.isUserInteractionEnabled = true
    textField.textContentType = .oneTimeCode
    textField.keyboardType = .numberPad
    textField.borderStyle = .roundedRect
    textField.placeholder = "------"
    
    textField.addTarget(context.coordinator, action: #selector(Coordinator.onTextChange), for: .editingChanged)
    textField.addTarget(context.coordinator, action: #selector(Coordinator.onSubmit), for: .editingDidEndOnExit)
    
    if becomesFirstResponder {
      textField.becomeFirstResponder()
    }
    
    return textField
  }
  
  func updateUIView(_ uiView: UITextField, context: Context) {
    if code == "" {
      uiView.text = nil
    } else {
      uiView.text = code
    }
  }
  
  class Coordinator : NSObject, UITextFieldDelegate {
    var parent: VerificationCodeField
    
    var observer: NSKeyValueObservation?
    
    init(_ uiTextView: VerificationCodeField) {
      self.parent = uiTextView
    }
    
    @objc func onTextChange(_ sender: UITextField) {
      self.parent.code = sender.text ?? ""
    }
    
    @objc func onSubmit(_ sender: UITextField) {
      self.parent.onSubmit?()
    }
  }
}



struct VerificationCodeField_Previews: PreviewProvider {
  struct StateView: View {
    @State var text = "1234"
    var body: some View {
      VStack {
        VerificationCodeField(code: $text)
        
        TextField("text", text: $text)
      }
    }
  }
  static var previews: some View {
    VerificationCodeField(code: .constant("123456"))
      .frame(width: 200, height: 50)
    VerificationCodeField(code: .constant("1"))
      .frame(width: 200, height: 50)
      .preferredColorScheme(.dark)
    
    VerificationCodeField(code: .constant("1"))
      .preferredColorScheme(.dark)
    
    StateView()
      .frame(width: 200, height: 50)
  }
}
#else

struct VerificationCodeField: View {
  @Binding var code: String
  var onSubmit: (()->())? = nil
  var becomesFirstResponder = true
  var body: some View {
    Button("Test"){}
  }
}
  

#endif
