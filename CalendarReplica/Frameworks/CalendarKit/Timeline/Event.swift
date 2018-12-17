import UIKit

open class Event: EventDescriptor {
  public var startDate = Date() //EVENTDATA SQLITE
  public var id: Int = 0
  public var repeatCount: Int = 0
  public var endDate = Date()
  public var lastDate = Date()
  public var startTime = ""
  public var endTime = ""
  public var date = ""
  public var isAllDay = false
  public var text = ""
  public var attributedText: NSAttributedString?
  public var color = UIColor.purple {
    didSet {
      backgroundColor = color.withAlphaComponent(0.3)
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
  }
  public var backgroundColor = UIColor.purple.withAlphaComponent(0.2)
  public var textColor = UIColor.black
  public var font = UIFont.boldSystemFont(ofSize: 12)
  public var userInfo: Any?
  public init() {}

}
