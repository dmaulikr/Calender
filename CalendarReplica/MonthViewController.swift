//
//  MonthViewController.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/22/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import CVCalendar
import SQLite3

class DayViewCell: UITableViewCell {
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
}

class MonthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var db: OpaquePointer?
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var lblDayTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var events = [DefaultEvent]()
    var tblList = [TableData]()
    var text = ""
    var PastEvents = [Event]()
    var TodayEvents = [Event]()
    var UpcomingEvents = [Event]()
    
    var currentDate: Date = Date()
    var todayDate: Date = Date()
    var date: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        menuView.delegate = self
        calendarView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLabelDate()
        
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL1 = DocumentDirURL.appendingPathComponent("calendar").appendingPathExtension("sqlite")
        
        if sqlite3_open(fileURL1.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        text = df.string(from: currentDate)
        monthData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    
    func monthData(){
        TodayEvents.removeAll()
        PastEvents.removeAll()
        TodayEvents = EventManager.manager.currentEvents
        for index in 0..<TodayEvents.count{
            let eve : Event
            eve = TodayEvents[index]
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yy"
           let day = df.string(from: eve.startDate)
            print(day)
            if day == text{
                PastEvents.append(eve)
            }
        }
        self.tableView.reloadData()
    }
    
    class TableData {
        
        var id: Int
        var title: String?
        var startTime: String?
        var endTime: String?
        var date: String?
        
        init(id: Int, title: String?,startTime: String?,endTime: String?,date: String?){
            self.id = id
            self.title = title
            self.startTime = startTime
            self.endTime = endTime
            self.date = date
        }
    }
    
    func updateLabelDate() {
        DispatchQueue.main.async {
            if self.currentDate.isToday {
                self.lblDayTitle.text = "Today"
            } else {
                let df = DateFormatter()
                df.dateFormat = "dd MMMM, YYYY"
                self.lblDayTitle.text = df.string(from: self.currentDate)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PastEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell

        let hero: Event
        hero = PastEvents[indexPath.row]
        cell.lblDescription.text = hero.text
        let strStartTime = hero.startTime
        let strEndTime = hero.endTime
        cell.lblTime.text = "\(strStartTime) - \(strEndTime)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension MonthViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentedDateUpdated(_ date: CVDate) {
        let str = String(date.year)
        let result4 = String(str.dropFirst(2))
        var m = String(date.month)
        var d = String(date.day)
        
        if m.count == 1 {
            m = "0\(m)"
        }
        
        if d.count == 1 {
            d = "0\(d)"
        }
        
        text = "\(m)/\(d)/\(result4)"
        currentDate = date.convertedDate()!
        updateLabelDate()
        monthData()

    }
    
    func presentationMode() -> CalendarMode {
        return CalendarMode.monthView
    }
    
    func firstWeekday() -> Weekday {
        return Weekday.monday
    }
}


/*
 func dataCall(){
 
 let queryString = "SELECT * FROM tblEvent WHERE date = ?;"
 var stmt:OpaquePointer?
 
 let strDate = text as NSString
 
 //preparing the query
 if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
 let errmsg = String(cString: sqlite3_errmsg(db)!)
 print("error preparing insert: \(errmsg)")
 return
 }
 
 if sqlite3_bind_text(stmt, 1, strDate.utf8String, -1, nil) != SQLITE_OK{
 let errmsg = String(cString: sqlite3_errmsg(db)!)
 print("failure binding name: \(errmsg)")
 return
 }
 
 tblList.removeAll()
 
 while(sqlite3_step(stmt) == SQLITE_ROW){
 let id = sqlite3_column_int(stmt, 0)
 let title = String(cString: sqlite3_column_text(stmt, 1))
 let startTime = String(cString: sqlite3_column_text(stmt, 2))
 let endTime = String(cString: sqlite3_column_text(stmt, 3))
 let date = String(cString: sqlite3_column_text(stmt, 4))
 
 
 tblList.append(TableData(id: Int(id), title: String(describing: title),startTime: String(describing: startTime),endTime: String(describing: endTime),date: String(describing: date)))
 }
 print(text)
 print(tblList.count)
 
 self.tableView.reloadData()
 }
 */
