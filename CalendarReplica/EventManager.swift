//
//  EventManager.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/24/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

class EventManager {
    
    var db: OpaquePointer?
    var arrEventData: NSMutableArray = []
    var tblList = [TableData]()
    static let manager = EventManager()

    var currentEvents = [Event]()
    
    var colors = [UIColor.blue,
                  UIColor.yellow,
                  UIColor.green,
                  UIColor.red]
    
    func fillDummyEvent() {
        
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL1 = DocumentDirURL.appendingPathComponent("calendar").appendingPathExtension("sqlite")
        
        
        
        if sqlite3_open(fileURL1.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else{
            
            let queryString = "SELECT * FROM tblEvent"
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            tblList.removeAll()
            
            //traversing through all the records
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let id = sqlite3_column_int(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let startTime = String(cString: sqlite3_column_text(stmt, 2))
                let endTime = String(cString: sqlite3_column_text(stmt, 3))
                let date = String(cString: sqlite3_column_text(stmt, 4))
                let repeatCount = sqlite3_column_int(stmt, 6)
                let lastDate = String(cString: sqlite3_column_text(stmt, 5))
                
                //adding values to list
                tblList.append(TableData(id: Int(id), title: String(describing: title),startTime: String(describing: startTime),endTime: String(describing: endTime),date: String(describing: date),repeatCount:Int(repeatCount),lastDate: String(describing: lastDate)))
                
            }
            
            
            currentEvents.removeAll()
            
            for index in 0..<tblList.count {
                let hero: TableData
                hero = tblList[index]
              
                let rep = hero.repeatCount
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy" //Your date format
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            //  dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                
                var date = dateFormatter.date(from: hero.date!)
                let lastDate = dateFormatter.date(from: hero.lastDate!)
                
                print("hero date: \(hero.date!)")
                print("hero lastdate: \(hero.lastDate!)")
                print("date: \(date!)")
                print("lastdate: \(lastDate!)")
                
                let endIndex = hero.startTime!.index(hero.startTime!.endIndex, offsetBy: -3)
                let strStartTime = hero.startTime!.substring(to: endIndex)
                let endIndex1 = hero.endTime!.index(hero.endTime!.endIndex, offsetBy: -3)
                let strEndTime = hero.endTime!.substring(to: endIndex1)
                
                
                let Start2Hr = String(hero.startTime!.suffix(2))
                let End2Hr = String(hero.endTime!.suffix(2))
                
                
                let start:Int? = Int(strStartTime)
                let end:Int? = Int(strEndTime)
                
                let startHr:Int? = Int(Start2Hr)
                let endHr:Int? = Int(End2Hr)
                
                
                switch (rep){
                case 0:
                    print("No Repeat")

                    let event = Event()
                    event.id = hero.id
                    event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                    event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                    event.text = hero.title!
                    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                    event.startTime = hero.startTime!
                    event.endTime = hero.endTime!
                    event.date = hero.date!
                    currentEvents.append(event)
                    
                    
                    break
                case 1:
                    print("Daily")
                    
                    let event = Event()
                    event.id = hero.id
                    event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                    event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                    event.text = hero.title!
                    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                    event.startTime = hero.startTime!
                    event.endTime = hero.endTime!
                    event.date = hero.date!
                    currentEvents.append(event)
                    
                    while date! < lastDate! {
                        date = Calendar.current.date(byAdding: .day, value: 1, to: date!)!
                        if date! <= lastDate!{
                            let event = Event()
                            event.id = hero.id
                            event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                            event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                            event.text = hero.title!
                            event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                            event.startTime = hero.startTime!
                            event.endTime = hero.endTime!
                            event.date = hero.date!
                            currentEvents.append(event)
                        }
                    }
                    break
                    
                case 2:
                    print("Weekly")

                    let event = Event()
                    event.id = hero.id
                    event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                    event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                    event.text = hero.title!
                    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                    event.startTime = hero.startTime!
                    event.endTime = hero.endTime!
                    event.date = hero.date!
                    currentEvents.append(event)
                    
                    while date! < lastDate! {
                        date = Calendar.current.date(byAdding: .day, value: 7,  to: date!)!
                        if date! <= lastDate!{
                            let event = Event()
                            event.id = hero.id
                            event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                            event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                            event.text = hero.title!
                            event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                            event.startTime = hero.startTime!
                            event.endTime = hero.endTime!
                            event.date = hero.date!
                            currentEvents.append(event)
                        }
                    }
                    break
                case 3:
                    print("Monthly")

                    let event = Event()
                    event.id = hero.id
                    event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                    event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                    event.text = hero.title!
                    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                    event.startTime = hero.startTime!
                    event.endTime = hero.endTime!
                    event.date = hero.date!
                    currentEvents.append(event)
                    
                    while date! < lastDate! {
                        date = Calendar.current.date(byAdding: .month, value: 1,  to: date!)!
                        
                        if date! <= lastDate!{
                            let event = Event()
                            event.id = hero.id
                            event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                            event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                            event.text = hero.title!
                            event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                            event.startTime = hero.startTime!
                            event.endTime = hero.endTime!
                            event.date = hero.date!
                            currentEvents.append(event)
                        }
                    }
                    
                    break
                case 4:
                    print("Yearly")
                    
                    let event = Event()
                    event.id = hero.id
                    event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                    event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                    event.text = hero.title!
                    event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                    event.startTime = hero.startTime!
                    event.endTime = hero.endTime!
                    event.date = hero.date!
                    currentEvents.append(event)
                    
                    while date! < lastDate! {
                        date = Calendar.current.date(byAdding: .year, value: 1,  to: date!)!
                        if date! < lastDate!{
                            let event = Event()
                            event.id = hero.id
                            event.startDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: start!, minute: startHr!, second: 0)
                            event.endDate = Date(year: date!.year, month: date!.month, day: date!.day, hour: end!, minute: endHr!, second: 0)
                            event.text = hero.title!
                            event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                            event.startTime = hero.startTime!
                            event.endTime = hero.endTime!
                            event.date = hero.date!
                            currentEvents.append(event)
                        }
                    }
                    
                    break
                default:
                    print("No Repeat")
                }
            }
        }
    }
}

class TableData {
    
    var id: Int
    var title: String?
    var startTime: String?
    var endTime: String?
    var date: String?
    var repeatCount: Int
    var lastDate: String?
    
    init(id: Int, title: String?,startTime: String?,endTime: String?,date: String?,repeatCount: Int, lastDate: String?){
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.repeatCount = repeatCount
        self.lastDate = lastDate
    }
}

