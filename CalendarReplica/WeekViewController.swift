//
//  WeekViewController.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/22/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import JZCalendarWeekView

class WeekViewController: UIViewController {
    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadEvents() {
        var events = [DefaultEvent]()
        var index = 0
        for e in EventManager.manager.currentEvents {
            let event = DefaultEvent(id: "\(index)", title: e.text, startDate: e.startDate, endDate: e.endDate, location: "")
            
            events.append(event)
            index += 1
        }
        calendarWeekView.setupCalendar(numOfDays: 7,
                                       setDate: Date(),
                                       allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events),
                                       scrollType: .pageScroll,
                                       firstDayOfWeek: .Monday)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew]
        reloadEvents()
    }
}

extension WeekViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {
    
    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        print(startDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        print(startDate)
    }
    
    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        let view = UINib(nibName: "EventCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EventCell
        view.titleLabel.text = "New Event"
        return view
    }
}
