import UIKit
import DateToolsSwift

class DateLabel: UILabel, DaySelectorItemProtocol {
  
  var date = Date() {
    didSet {
      text = String(date.day)
      updateState()
    }
  }

  var selected: Bool = false {
    didSet {
      animate()
    }
  }

  var style = DaySelectorStyle()

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 35, height: 35)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    isUserInteractionEnabled = true
    textAlignment = .center
    clipsToBounds = true
  }

  func updateStyle(_ newStyle: DaySelectorStyle) {
    style = newStyle
    updateState()
  }

  func updateState() {
    let today = date.isToday
    let Currdate = Date()
    
    
    
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
    UserDefaults.standard.set(date, forKey:"yourKey")
    UserDefaults.standard.set(tomorrow, forKey:"yourKey1")
    
    if date < Currdate{
        if today{
            UserDefaults.standard.set(1, forKey: "intKey1")
        }
        else{
            UserDefaults.standard.set(0, forKey: "intKey1")
        }
    }
    else if date > Currdate{
        UserDefaults.standard.set(2, forKey: "intKey1")
    }
    
    if selected {
      font = style.todayFont
      textColor = style.activeTextColor
      backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
    } else {
      let notTodayColor = date.isWeekend ? style.weekendTextColor : style.inactiveTextColor
      font = style.font
      textColor = today ? style.todayInactiveTextColor : notTodayColor
      backgroundColor = style.inactiveBackgroundColor
    }
  }

  func animate(){
    UIView.transition(with: self,
                      duration: 0.4,
                      options: .transitionCrossDissolve,
                      animations: {
                        self.updateState()
    }, completion: nil)
  }

  override func layoutSubviews() {
    layer.cornerRadius = bounds.height / 2
  }
  override func tintColorDidChange() {
    updateState()
  }
}
