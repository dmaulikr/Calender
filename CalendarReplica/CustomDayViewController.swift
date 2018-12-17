//
//  CustomDayViewController.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/23/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import DateToolsSwift

class CustomDayViewController: DayViewController {
    var tempEvent: Event?
    var startedDragginHour: Int = 0
    var saveEventOpened: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(1, forKey: "intKey1")
        UserDefaults.standard.set(Date(), forKey:"yourKey")
        UserDefaults.standard.set(Date(), forKey:"yourKey1")
        dayView.autoScrollToFirstEvent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set(Date(), forKey:"yourKey")
        UserDefaults.standard.set(Date(), forKey:"yourKey1")
        
        self.dayView.state?.move(to: Date())
        self.dayView.reloadData()
        
        
    }
    
    var date = Date() {
        didSet {
           var text = String(date.day)
            print(text)
        }
    }
    
    override func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
        
        let Currdate = Date() // save date, so all components use the same date
        let Currcalendar = Calendar.current // or e.g. Calendar(identifier: .persian)
        let Currhour = Currcalendar.component(.hour, from: Currdate)
        
        let returnValue = UserDefaults.standard.object(forKey: "intKey1") as! Int
        let tommorow = UserDefaults.standard.object(forKey: "yourKey") as! Date
        
        
        let nextHour: Int = hour + Int(0.5)
        print(nextHour)
        
        if returnValue == 1 { //Today
            if hour < Currhour{
                UserDefaults.standard.set(0, forKey: "intKey")
            }
            else{
                UserDefaults.standard.set(1, forKey: "intKey")
                tempEvent = Event()
                startedDragginHour = hour
                tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 0, second: 0)
                tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour+1, minute: 0, second: 0)
                tempEvent!.text = "New Event"
                self.dayView.reloadData()
            }
        }
        
        if returnValue == 2 { //Tomorrow
            UserDefaults.standard.set(1, forKey: "intKey")
            tempEvent = Event()
            startedDragginHour = hour
            tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 0, second: 0)
            tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour + 1, minute: 0, second: 0)
            tempEvent!.text = "New Event"
            tempEvent!.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
            self.dayView.reloadData()
        }
        
        if returnValue == 0{ //YESTERDAY
            UserDefaults.standard.set(0, forKey: "intKey")
        }
    }
    
    override func dayViewDidMoveLongPressTimelineAtHour(_ hour: Int) {
      //  print("long press move \(hour)")
    }
    
    override func dayViewDidReleaseLongPressTimelineAtHour(_ hour: Int) {
        let tommorow = UserDefaults.standard.object(forKey: "yourKey") as! Date
        
       if hour != 0 {
            if tempEvent != nil {
                var beginHour = startedDragginHour
                var endHour = hour
                if beginHour > endHour {
                    beginHour = hour
                    endHour = startedDragginHour + 1
                }
                if beginHour == endHour {
                    endHour = beginHour + 1
                }
                tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: beginHour, minute: 0, second: 0)
                tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: endHour, minute: 0, second: 0)
               dayView.scrollTo(hour24: Float(endHour))
            }
            self.dayView.reloadData()
        } else {
            if !saveEventOpened {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveEventViewController") as! SaveEventViewController
                vc.event = self.tempEvent
                vc.isEventUpdateFlag = false
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
                saveEventOpened = true
            }
        }
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveEventViewController") as! SaveEventViewController
        vc.isOld = 0
        
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)) as Date
        let tommorow = UserDefaults.standard.object(forKey: "yourKey1") as! Date

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minutes = calendar.component(.minute, from: time)
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone =  TimeZone(abbreviation: "UTC")
        let strEventTime = df.string(from: tommorow)
        let strToday = df.string(from: time)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" //Your date format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
        
        let EventDate = dateFormatter.date(from: strEventTime) as! Date
        let todayDate = dateFormatter.date(from: strToday) as! Date
        let order = Calendar.current.compare(todayDate, to: EventDate, toGranularity: .day)
        
        switch order {
        case .orderedDescending:
            print("DESCENDING")
            vc.isOld = 1
        case .orderedAscending:
            print("ASCENDING")
        case .orderedSame:
            print("SAME")
            
            let eventHour = eventView.descriptor!.startTime
            let endIndex = eventHour.index(eventHour.endIndex, offsetBy: -3)
            let strEveTime = eventHour.substring(to: endIndex)
            let EventH:Int? = Int(strEveTime)
            let CurrH = Int(hour)
            if EventH! < CurrH{
                vc.isOld = 1
            }
        }
        
            print(eventView.descriptor!.id)
            vc.EventID = eventView.descriptor!.id
            vc.isEventUpdateFlag = true
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            saveEventOpened = true
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone =  TimeZone(abbreviation: "UTC")
        let strEventTime = df.string(from: date)
        let strToday = df.string(from: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" //Your date format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
        
        let EventDate = dateFormatter.date(from: strEventTime) as! Date
        let todayDate = dateFormatter.date(from: strToday) as! Date
        
        var events = EventManager.manager.currentEvents
        print(date)
        if tempEvent != nil {
            events.append(tempEvent!)
        }
        
        let Currdate = Date() // save date, so all components use the same date
        let Currcalendar = Calendar.current // or e.g. Calendar(identifier: .persian)
        let Currhour = Currcalendar.component(.hour, from: Currdate)
        return events
    }
}

extension CustomDayViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CustomDayViewController: SaveEventViewControllerProtocol {
    func eventDidSave() {
        saveEventOpened = false
        tempEvent = nil
        dayView.reloadData()
    }
    
    func eventDidCancel() {
        saveEventOpened = false
        tempEvent = nil
        dayView.reloadData()
    }
    
    func eventDidUpdate() {
        saveEventOpened = false
        tempEvent = nil
        dayView.reloadData()
    }
}

/*
 //
 //  CustomDayViewController.swift
 //  CalendarReplica
 //
 //  Created by Anton Semenyuk on 10/23/18.
 //  Copyright © 2018 Anton Semenyuk. All rights reserved.
 //
 
 import Foundation
 import UIKit
 import DateToolsSwift
 
 class CustomDayViewController: DayViewController {
 var tempEvent: Event?
 var startedDragginHour: Int = 0
 var saveEventOpened: Bool = false
 
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 UserDefaults.standard.set(1, forKey: "intKey1")
 UserDefaults.standard.set(Date(), forKey:"yourKey")
 UserDefaults.standard.set(Date(), forKey:"yourKey1")
 dayView.autoScrollToFirstEvent = true
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 UserDefaults.standard.set(Date(), forKey:"yourKey")
 UserDefaults.standard.set(Date(), forKey:"yourKey1")
 
 self.dayView.state?.move(to: Date())
 
 self.dayView.reloadData()
 
 
 }
 
 var date = Date() {
 didSet {
 var text = String(date.day)
 print(text)
 }
 }
 
 override func dayViewDidLongPressTimelineAtHour(_ hour: Int) {
 
 let Currdate = Date() // save date, so all components use the same date
 let Currcalendar = Calendar.current // or e.g. Calendar(identifier: .persian)
 let Currhour = Currcalendar.component(.hour, from: Currdate)
 
 let returnValue = UserDefaults.standard.object(forKey: "intKey1") as! Int
 let tommorow = UserDefaults.standard.object(forKey: "yourKey") as! Date
 
 
 let nextHour: Int = hour + Int(0.5)
 print(nextHour)
 
 if returnValue == 1 { //Today
 if hour < Currhour{
 UserDefaults.standard.set(0, forKey: "intKey")
 }
 else{
 UserDefaults.standard.set(1, forKey: "intKey")
 tempEvent = Event()
 startedDragginHour = hour
 tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 0, second: 0)
 tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 30, second: 0)
 tempEvent!.text = "New Event"
 self.dayView.reloadData()
 }
 }
 
 if returnValue == 2 { //Tomorrow
 UserDefaults.standard.set(1, forKey: "intKey")
 tempEvent = Event()
 startedDragginHour = hour
 tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 0, second: 0)
 tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: hour, minute: 30, second: 0)
 tempEvent!.text = "New Event"
 tempEvent!.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
 self.dayView.reloadData()
 }
 
 if returnValue == 0{ //YESTERDAY
 UserDefaults.standard.set(0, forKey: "intKey")
 }
 }
 
 override func dayViewDidMoveLongPressTimelineAtHour(_ hour: Int) {
 //  print("long press move \(hour)")
 }
 
 override func dayViewDidReleaseLongPressTimelineAtHour(_ hour: Int) {
 let tommorow = UserDefaults.standard.object(forKey: "yourKey") as! Date
 
 if hour != 0 {
 if tempEvent != nil {
 var beginHour = startedDragginHour
 var endHour = hour
 if beginHour > endHour {
 beginHour = hour
 endHour = startedDragginHour
 }
 if beginHour == endHour {
 endHour = beginHour
 }
 
 tempEvent!.startDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: beginHour, minute: 0, second: 0)
 tempEvent!.endDate = Date(year: tommorow.year, month: tommorow.month, day: tommorow.day, hour: endHour, minute: 30, second: 0)
 dayView.scrollTo(hour24: Float(endHour))
 }
 self.dayView.reloadData()
 } else {
 if !saveEventOpened {
 let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveEventViewController") as! SaveEventViewController
 vc.event = self.tempEvent
 vc.isEventUpdateFlag = false
 vc.delegate = self
 self.navigationController?.pushViewController(vc, animated: true)
 saveEventOpened = true
 }
 }
 }
 
 override func dayViewDidSelectEventView(_ eventView: EventView) {
 
 let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SaveEventViewController") as! SaveEventViewController
 vc.isOld = 0
 
 let timestamp = NSDate().timeIntervalSince1970
 let myTimeInterval = TimeInterval(timestamp)
 let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)) as Date
 let tommorow = UserDefaults.standard.object(forKey: "yourKey1") as! Date
 
 let calendar = Calendar.current
 let hour = calendar.component(.hour, from: time)
 let minutes = calendar.component(.minute, from: time)
 
 let df = DateFormatter()
 df.dateFormat = "MM/dd/yy"
 df.locale = Locale(identifier: "en_US_POSIX")
 df.timeZone =  TimeZone(abbreviation: "UTC")
 let strEventTime = df.string(from: tommorow)
 let strToday = df.string(from: time)
 
 let dateFormatter = DateFormatter()
 dateFormatter.dateFormat = "MM/dd/yy" //Your date format
 dateFormatter.locale = Locale(identifier: "en_US_POSIX")
 dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
 
 let EventDate = dateFormatter.date(from: strEventTime) as! Date
 let todayDate = dateFormatter.date(from: strToday) as! Date
 
 let order = Calendar.current.compare(todayDate, to: EventDate, toGranularity: .day)
 
 switch order {
 case .orderedDescending:
 print("DESCENDING")
 vc.isOld = 1
 case .orderedAscending:
 print("ASCENDING")
 case .orderedSame:
 print("SAME")
 
 let eventHour = eventView.descriptor!.startTime
 let endIndex = eventHour.index(eventHour.endIndex, offsetBy: -3)
 let strEveTime = eventHour.substring(to: endIndex)
 let EventH:Int? = Int(strEveTime)
 let CurrH = Int(hour)
 if EventH! < CurrH{
 vc.isOld = 1
 }
 }
 
 
 if tommorow<time {
 print("Old date!!!")
 }
 else{
 print(eventView.descriptor!.id)
 vc.EventID = eventView.descriptor!.id
 vc.isEventUpdateFlag = true
 vc.delegate = self
 self.navigationController?.pushViewController(vc, animated: true)
 saveEventOpened = true
 }
 }
 
 override func eventsForDate(_ date: Date) -> [EventDescriptor] {
 var events = EventManager.manager.currentEvents
 if tempEvent != nil {
 events.append(tempEvent!)
 }
 let Currdate = Date() // save date, so all components use the same date
 let Currcalendar = Calendar.current // or e.g. Calendar(identifier: .persian)
 let Currhour = Currcalendar.component(.hour, from: Currdate)
 // dayView.scrollTo(hour24: Float(Currhour))
 
 return events
 }
 }
 
 extension CustomDayViewController: UIGestureRecognizerDelegate {
 func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
 return true
 }
 }
 
 extension CustomDayViewController: SaveEventViewControllerProtocol {
 func eventDidSave() {
 saveEventOpened = false
 tempEvent = nil
 dayView.reloadData()
 }
 
 func eventDidCancel() {
 saveEventOpened = false
 tempEvent = nil
 dayView.reloadData()
 }
 
 func eventDidUpdate() {
 saveEventOpened = false
 tempEvent = nil
 dayView.reloadData()
 }
 }

 */
