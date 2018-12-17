import UIKit
import Neon
import DateToolsSwift

public protocol TimelineViewDelegate: AnyObject {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int)
    func timelineView(_ timelineView: TimelineView, didReleaseLongPressAt hour: Int)
    func timelineView(_ timelineView: TimelineView, didMoveLongPressAt hour: Int)
}

public class TimelineView: UIView, ReusableView {

  public weak var delegate: TimelineViewDelegate?

  public weak var eventViewDelegate: EventViewDelegate? {
    didSet {
      self.allDayView.eventViewDelegate = eventViewDelegate
    }
  }

  public var date = Date() {
    didSet {
      setNeedsLayout()
    }
  }

  var currentTime: Date {
    return Date()
  }

  var eventViews = [EventView]()
  public private(set) var regularLayoutAttributes = [EventLayoutAttributes]()
  public private(set) var allDayLayoutAttributes = [EventLayoutAttributes]()
  
  public var layoutAttributes: [EventLayoutAttributes] {
    set {
      
      // update layout attributes by separating allday from non all day events
      allDayLayoutAttributes.removeAll()
      regularLayoutAttributes.removeAll()
      for anEventLayoutAttribute in newValue {
        let eventDescriptor = anEventLayoutAttribute.descriptor
        if eventDescriptor.isAllDay {
          allDayLayoutAttributes.append(anEventLayoutAttribute)
        } else {
          regularLayoutAttributes.append(anEventLayoutAttribute)
        }
      }
      
      recalculateEventLayout()
      prepareEventViews()
      allDayView.events = allDayLayoutAttributes.map { $0.descriptor }
      allDayView.isHidden = allDayLayoutAttributes.count == 0
      allDayView.scrollToBottom()
      
      setNeedsLayout()
    }
    get {
      return allDayLayoutAttributes + regularLayoutAttributes
    }
  }
  var pool = ReusePool<EventView>()

  var firstEventYPosition: CGFloat? {
    return regularLayoutAttributes.sorted{$0.frame.origin.y < $1.frame.origin.y}
      .first?.frame.origin.y
  }

  lazy var nowLine: CurrentTimeIndicator = CurrentTimeIndicator()
  
  private var allDayViewTopConstraint: NSLayoutConstraint?
  lazy var allDayView: AllDayView = {
    let allDayView = AllDayView(frame: CGRect.zero)
    
    allDayView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(allDayView)

    self.allDayViewTopConstraint = allDayView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    self.allDayViewTopConstraint?.isActive = true

    allDayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
    allDayView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true

    return allDayView
  }()
  
  var allDayViewHeight: CGFloat {
    return allDayView.bounds.height
  }

  var style = TimelineStyle()

  var horizontalEventInset: CGFloat = 3

  public var fullHeight: CGFloat {
    return style.verticalInset * 2 + style.verticalDiff * 24
  }

  var calendarWidth: CGFloat {
    return bounds.width - style.leftInset
  }
    
  var is24hClock = true {
    didSet {
      setNeedsDisplay()
    }
  }

  init() {
    super.init(frame: .zero)
    frame.size.height = fullHeight
    configure()
  }

  var times: [String] {
    return is24hClock ? _24hTimes : _12hTimes
  }

  fileprivate lazy var _12hTimes: [String] = Generator.timeStrings24H()
  fileprivate lazy var _24hTimes: [String] = Generator.timeStrings24H()
  
  fileprivate lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))

  var isToday: Bool {
    return date.isToday
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    contentScaleFactor = 1
    layer.contentsScale = 1
    contentMode = .redraw
    backgroundColor = .white
    addSubview(nowLine)
    
    // Add long press gesture recognizer
    addGestureRecognizer(longPressGestureRecognizer)
  }
  
  @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if (gestureRecognizer.state == .began) {
      // Get timeslot of gesture location
      let pressedLocation = gestureRecognizer.location(in: self)
      let percentOfHeight = (pressedLocation.y - style.verticalInset) / (bounds.height - (style.verticalInset * 2))
      let pressedAtHour: Int = Int(24 * percentOfHeight)
      delegate?.timelineView(self, didLongPressAt: pressedAtHour) //Editing
    } else if (gestureRecognizer.state == .ended || gestureRecognizer.state == .failed || gestureRecognizer.state == .cancelled) {
        let returnValue = UserDefaults.standard.object(forKey: "intKey") as! Int
        if returnValue == 0{
           // delegate?.timelineView(self, didReleaseLongPressAt: 0)
        }
        else{
            delegate?.timelineView(self, didReleaseLongPressAt: 0)
        }
        
    } else {
        // Get timeslot of gesture location
        let pressedLocation = gestureRecognizer.location(in: self)
        let percentOfHeight = (pressedLocation.y - style.verticalInset) / (bounds.height - (style.verticalInset * 2))
       // print(percentOfHeight)
        let pressedAtHour: Int = Int(24 * percentOfHeight)
        delegate?.timelineView(self, didMoveLongPressAt: pressedAtHour)
    }
  }

  public func updateStyle(_ newStyle: TimelineStyle) {
    style = newStyle.copy() as! TimelineStyle
    nowLine.updateStyle(style.timeIndicator)
    
    switch style.dateStyle {
      case .twelveHour:
        is24hClock = false
        break
      case .twentyFourHour:
        is24hClock = true
        break
      default:
        is24hClock = Locale.autoupdatingCurrent.uses24hClock()
        break
    }
    
    backgroundColor = style.backgroundColor
    setNeedsDisplay()
  }
/*
  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    var hourToRemoveIndex = -1

    if isToday {
      let minute = currentTime.minute
      if minute > 39 {
        hourToRemoveIndex = currentTime.hour + 1
      } else if minute < 21 {
        hourToRemoveIndex = currentTime.hour
      }
    }

    let mutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    mutableParagraphStyle.lineBreakMode = .byWordWrapping
    mutableParagraphStyle.alignment = .right
    let paragraphStyle = mutableParagraphStyle.copy() as! NSParagraphStyle
    
    let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
					  NSAttributedString.Key.foregroundColor: self.style.timeColor,
					  NSAttributedString.Key.font: style.font] as [NSAttributedString.Key : Any]

    for (i, time) in times.enumerated() {
      let iFloat = CGFloat(i)
      let context = UIGraphicsGetCurrentContext()
      context!.interpolationQuality = .none
      context?.saveGState()
      context?.setStrokeColor(self.style.lineColor.cgColor)
      context?.setLineWidth(onePixel)
      context?.translateBy(x: 0, y: 0.5)
      let x: CGFloat = 53
      let y = style.verticalInset + iFloat * style.verticalDiff
      context?.beginPath()
      context?.move(to: CGPoint(x: x, y: y))
      context?.addLine(to: CGPoint(x: (bounds).width, y: y))
      context?.strokePath()
      context?.restoreGState()

      if i == hourToRemoveIndex { continue }
        
      let fontSize = style.font.pointSize
      let timeRect = CGRect(x: 2, y: iFloat * style.verticalDiff + style.verticalInset - 7,
                            width: style.leftInset - 8, height: fontSize + 2)

      let timeString = NSString(string: time)
        
      timeString.draw(in: timeRect, withAttributes: attributes)
    }
  }*/

    
     override public func draw(_ rect: CGRect) {
     super.draw(rect)
     
     var hourToRemoveIndex = -1
     
     if isToday {
     let minute = currentTime.minute
     if minute > 39 {
     hourToRemoveIndex = currentTime.hour + 1
     } else if minute < 21 {
     hourToRemoveIndex = currentTime.hour
     }
     }
     
     let mutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
     mutableParagraphStyle.lineBreakMode = .byWordWrapping
     mutableParagraphStyle.alignment = .right
     let paragraphStyle = mutableParagraphStyle.copy() as! NSParagraphStyle
     
     let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
     NSAttributedString.Key.foregroundColor: self.style.timeColor,
     NSAttributedString.Key.font: style.font] as [NSAttributedString.Key : Any]
     
     for (i, time) in times.enumerated() {
     let iFloat = CGFloat(i)
     let context = UIGraphicsGetCurrentContext()
     context!.interpolationQuality = .none
     context?.saveGState()
     context?.setStrokeColor(self.style.lineColor.cgColor)
     context?.setLineWidth(onePixel)
     context?.translateBy(x: 0, y: 0.5)
     let x: CGFloat = 53
     let y = style.verticalInset + iFloat * style.verticalDiff
     context?.beginPath()
     context?.move(to: CGPoint(x: x, y: y))
     context?.addLine(to: CGPoint(x: (bounds).width, y: y))
     context?.strokePath()
     context?.restoreGState()
     
     if i == hourToRemoveIndex { continue }
     
     let fontSize = style.font.pointSize
     let timeRect = CGRect(x: 2, y: iFloat * style.verticalDiff + style.verticalInset - 7,
     width: style.leftInset - 8, height: fontSize + 2)
     
     let timeString = NSString(string: time)
     
     // line to be added for 30 min interval
     let subLineContext = UIGraphicsGetCurrentContext()
     subLineContext!.interpolationQuality = .none
     subLineContext?.saveGState()
     subLineContext?.setStrokeColor(self.style.halfColor.cgColor)
     subLineContext?.setLineWidth(1)
     subLineContext?.translateBy(x: 0, y: 0)
     let halfHourX: CGFloat = 53
     let halfHourY = (style.verticalInset + iFloat * style.verticalDiff) + (style.verticalDiff/2)
     subLineContext?.beginPath()
     subLineContext?.move(to: CGPoint(x: halfHourX, y: halfHourY))
     subLineContext?.addLine(to: CGPoint(x: (bounds).width, y: halfHourY))
     subLineContext?.strokePath()
     
     //lines to be added for 15 min interval
     subLineContext?.setStrokeColor(self.style.halfColor.cgColor)
     let firstQuarterY = (style.verticalInset + iFloat * style.verticalDiff) + (style.verticalDiff/4)
     subLineContext?.beginPath()
     subLineContext?.move(to: CGPoint(x: halfHourX, y: firstQuarterY))
     subLineContext?.addLine(to: CGPoint(x: (bounds).width, y: firstQuarterY))
     subLineContext?.strokePath()
     
     subLineContext?.setStrokeColor(self.style.halfColor.cgColor)
     let secondQuarterY = (style.verticalInset + iFloat * style.verticalDiff) + ((style.verticalDiff/4) + (style.verticalDiff / 2))
     subLineContext?.beginPath()
     subLineContext?.move(to: CGPoint(x: halfHourX, y: secondQuarterY))
     subLineContext?.addLine(to: CGPoint(x: (bounds).width, y: secondQuarterY))
     subLineContext?.strokePath()
     
     //add half hour time string
     let halfHourTimeRect = CGRect(x: 2, y: (iFloat * style.verticalDiff + style.verticalInset - 7) + (style.verticalDiff/2),
     width: style.leftInset - 8, height: fontSize + 2)
     
     var halfHourTimeString = NSString()
     
     //To be changed in a better quality code with proper time references. This is a work around
     if is24hClock {
     halfHourTimeString = NSString(string: time.replacingOccurrences(of: ":00", with: ":30"))
     }else {
  //   halfHourTimeString = (time == "Noon") ? NSString(string: "12:30") : NSString(string: time.replacingOccurrences(of: " AM", with: ":30").replacingOccurrences(of: " PM", with: ":30"))
        halfHourTimeString = NSString(string: time.replacingOccurrences(of: ":00", with: ":30"))
     }
     
     timeString.draw(in: timeRect, withAttributes: attributes)
     
     halfHourTimeString.draw(in: halfHourTimeRect, withAttributes: attributes)
     }
}
    
    
    
    
  override public func layoutSubviews() {
    super.layoutSubviews()
    recalculateEventLayout()
    layoutEvents()
    layoutNowLine()
    layoutAllDayEvents()
  }

  func layoutNowLine() {
    if !isToday {
      nowLine.alpha = 0
    } else {
		bringSubviewToFront(nowLine)
      nowLine.alpha = 1
      let size = CGSize(width: bounds.size.width, height: 20)
      let rect = CGRect(origin: CGPoint.zero, size: size)
      nowLine.date = currentTime
      nowLine.frame = rect
      nowLine.center.y = dateToY(currentTime)
    }
  }

  func layoutEvents() {
    if eventViews.isEmpty {return}
    
    for (idx, attributes) in regularLayoutAttributes.enumerated() {
      let descriptor = attributes.descriptor
      let eventView = eventViews[idx]
      eventView.frame = attributes.frame
      eventView.updateWithDescriptor(event: descriptor)
    }
  }
  
  func layoutAllDayEvents() {
    
    //add day view needs to be in front of the nowLine
	bringSubviewToFront(allDayView)
  }
  
  /**
   This will keep the allDayView as a staionary view in its superview
   
   - parameter yValue: since the superview is a scrollView, `yValue` is the
   `contentOffset.y` of the scroll view
   */
  func offsetAllDayView(by yValue: CGFloat) {
    if let topConstraint = self.allDayViewTopConstraint {
      topConstraint.constant = yValue
      layoutIfNeeded()
    }
  }

  func recalculateEventLayout() {
    
    // only non allDay events need their frames to be set
    let sortedEvents = self.regularLayoutAttributes.sorted { (attr1, attr2) -> Bool in
      let start1 = attr1.descriptor.startDate
      let start2 = attr2.descriptor.startDate
      return start1.isEarlier(than: start2)
    }

    var groupsOfEvents = [[EventLayoutAttributes]]()
    var overlappingEvents = [EventLayoutAttributes]()

    for event in sortedEvents {
      if overlappingEvents.isEmpty {
        overlappingEvents.append(event)
        continue
      }

      let longestEvent = overlappingEvents.sorted { (attr1, attr2) -> Bool in
        let period1 = attr1.descriptor.datePeriod.seconds
        let period2 = attr2.descriptor.datePeriod.seconds
        return period1 > period2
        }
        .first!

        if style.eventsWillOverlap {
         /* guard let earliestEvent = overlappingEvents.first?.descriptor.startDate else { continue }
            let dateInterval = getDateInterval(date: earliestEvent)
            if event.descriptor.datePeriod.relation(to: dateInterval) == Relation.startInside {
                //overlappingEvents.append(event)
             //   continue
            }*/
        } else {
            let lastEvent = overlappingEvents.last!
//            print(longestEvent.descriptor.startDate)
//            print(longestEvent.descriptor.endDate)
//            print(lastEvent.descriptor.startDate)
//            print(lastEvent.descriptor.endDate)
//            print(event.descriptor.startDate)
//            print(event.descriptor.endDate)
            if longestEvent.descriptor.datePeriod.overlaps(with: event.descriptor.datePeriod) ||
                lastEvent.descriptor.datePeriod.overlaps(with: event.descriptor.datePeriod) {
                overlappingEvents.append(event)
                continue
            }
        }
        groupsOfEvents.append(overlappingEvents)
        overlappingEvents = [event]
    }
    
    if style.eventsWillOverlap {
        print("OVERLAP")
    }

   // print(overlappingEvents)
    
    groupsOfEvents.append(overlappingEvents)
    overlappingEvents.removeAll()

    for overlappingEvents in groupsOfEvents {
      let totalCount = CGFloat(overlappingEvents.count)
      for (index, event) in overlappingEvents.enumerated() {
        let startY = dateToY(event.descriptor.datePeriod.beginning!)
        let endY = dateToY(event.descriptor.datePeriod.end!)
        let floatIndex = CGFloat(index)
        let x = style.leftInset + floatIndex / totalCount * calendarWidth
        let equalWidth = calendarWidth / totalCount
        event.frame = CGRect(x: x, y: startY, width: equalWidth, height: endY - startY)
      }
    }
  }

  func prepareEventViews() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    for _ in 0...regularLayoutAttributes.endIndex {
      let newView = pool.dequeue()
      newView.delegate = eventViewDelegate
      if newView.superview == nil {
        addSubview(newView)
      }
      eventViews.append(newView)
    }
  }

  func prepareForReuse() {
    pool.enqueue(views: eventViews)
    eventViews.removeAll()
    setNeedsDisplay()
  }

  // MARK: - Helpers

  fileprivate var onePixel: CGFloat {
    return 1 / UIScreen.main.scale
  }

  fileprivate func dateToY(_ date: Date) -> CGFloat {
    if date.dateOnly() > self.date.dateOnly() {
      // Event ending the next day
      return 24 * style.verticalDiff + style.verticalInset
    } else if date.dateOnly() < self.date.dateOnly() {
      // Event starting the previous day
      return style.verticalInset
    } else {
      let hourY = CGFloat(date.hour) * style.verticalDiff + style.verticalInset
      let minuteY = CGFloat(date.minute) * style.verticalDiff / 60
      return hourY + minuteY
    }
  }

  fileprivate func getDateInterval(date: Date) -> TimePeriod {
    let earliestEventMintues = date.minute
    let splitMinuteInterval = style.splitMinuteInterval
    let minuteRange = (date.minute / splitMinuteInterval) * splitMinuteInterval
    let beginningRange = Calendar.current.date(byAdding: .minute, value: -(earliestEventMintues - minuteRange), to: date)!
    let endRange = Calendar.current.date(byAdding: .minute, value: splitMinuteInterval, to: beginningRange)
    return TimePeriod.init(beginning: beginningRange, end: endRange)
  }
}