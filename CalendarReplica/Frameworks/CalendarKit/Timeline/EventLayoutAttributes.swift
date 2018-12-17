import Foundation
import UIKit

public class EventLayoutAttributes {
  public let descriptor: EventDescriptor
  public var frame = CGRect.zero

  public init(_ descriptor: EventDescriptor) {
    self.descriptor = descriptor
  }
}
