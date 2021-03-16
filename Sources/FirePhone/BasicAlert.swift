import Foundation
import SwiftUI

public struct AlertData: Identifiable  {
  public init(title: String, message: String) {
    self.title = title
    self.message = message
  }
  
  public let title: String
  public let message: String
  public var id: String { title + message }
  
  public var alert: Alert {
    return Alert(title: Text(title),
                 message: Text(message))
  }
}

public extension View {
  func alert(_ data: Binding<AlertData?>) -> some View {
    self.alert(item: data) { data in
      data.alert
    }
  }
}
