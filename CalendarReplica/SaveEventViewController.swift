//
//  SaveEventViewController.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/24/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import SQLite3
import ActionSheetPicker_3_0

protocol SaveEventViewControllerProtocol {
    func eventDidSave()
    func eventDidCancel()
    func eventDidUpdate()
}


class SaveEventViewController: UIViewController, UITextFieldDelegate {
    var db: OpaquePointer?
    var delegate: SaveEventViewControllerProtocol?
    var event: Event?
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var viewExtra: UIView!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblTypeOfService: UILabel!
    @IBOutlet weak var viewDistance: NSLayoutConstraint!
    @IBOutlet weak var lblFrequency: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var imgCheckBox1: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblRepeatType: UILabel!
    @IBOutlet weak var lblRepeatLastDate: UILabel!
    @IBOutlet weak var imgRepeatCheck: UIImageView!
    @IBOutlet weak var txtRepeatTime: UITextField!
    @IBOutlet weak var txtRepeatLastDate: UITextField!
    @IBOutlet weak var viewRepeatExtra: UIView!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtStartTime: UITextField!
    @IBOutlet weak var txtEndTime: UITextField!
    
    
    var i: Int = 0
    var iRepeat: Int = 0
    var lastRecordId: Int = 0
    var repeatEnable: Int = 0
    var i1: Int = 0
    var i2: Int = 0
    var EventID: Int = 0
    var isOld: Int = 0
    var isEventUpdateFlag: Bool = false
    
    var datePicker: UIDatePicker = UIDatePicker()
    var myArray : NSMutableArray = ["No Repeat","Daily","Weekly","Monthly","Yearly"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Event"
        event?.text = ""
        viewExtra.isHidden = true
        viewDistance.constant = 8
        viewRepeatExtra.isHidden = true
        btnDelete.isHidden = true
        
        self.txtRepeatLastDate.isUserInteractionEnabled = false
        
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL1 = DocumentDirURL.appendingPathComponent("calendar").appendingPathExtension("sqlite")
        
        if sqlite3_open(fileURL1.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        if isEventUpdateFlag {
            btnDelete.isHidden = false
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(handleUpdate))
            
            let queryString = "SELECT * FROM tblEvent WHERE id = ?;"
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int(stmt, 1, Int32(EventID)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //traversing through all the records
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let id = sqlite3_column_int(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let startTime = String(cString: sqlite3_column_text(stmt, 2))
                let endTime = String(cString: sqlite3_column_text(stmt, 3))
                let date = String(cString: sqlite3_column_text(stmt, 4))
                let EndDate = String(cString: sqlite3_column_text(stmt, 5))
                let repeatTime = sqlite3_column_int(stmt, 6)
                
                lblDate.text = date
                lblStartTime.text = startTime
                lblEndTime.text = endTime
                lblTypeOfService.text = title
                
                if repeatTime == 0{
                    iRepeat = 0
                }
                else if repeatTime == 1{
                    iRepeat = 1
                    txtRepeatTime.text = "Daily"
                    lblFrequency.text = "Daily"
                    txtRepeatLastDate.text = EndDate
                }
                else if repeatTime == 2{
                    iRepeat = 2
                    txtRepeatTime.text = "Weekly"
                    lblFrequency.text = "Weekly"
                    txtRepeatLastDate.text = EndDate
                }
                else if repeatTime == 3{
                    iRepeat = 3
                    txtRepeatTime.text = "Monthly"
                    lblFrequency.text = "Monthly"
                    txtRepeatLastDate.text = EndDate
                }
                else if repeatTime == 4{
                    iRepeat = 4
                    txtRepeatTime.text = "Yearly"
                    lblFrequency.text = "Yearly"
                    txtRepeatLastDate.text = EndDate
                }
                
            }
            
            if(lblTypeOfService.text == "Consumer Location, Virtual"){
                i1 = 1
                i2 = 1
            }
            else if(lblTypeOfService.text == "Virtual"){
                i1 = 0
                i2 = 1
            }
            else{
                i1 = 1
                i2 = 0
            }
            
            if i1 == 0 {
                imgCheckBox1.image = UIImage(named: "check_empty.png")
            } else if i1 == 1 {
                imgCheckBox.image = UIImage(named: "checked.png")
            }
            
            if i2 == 0 {
                imgCheckBox1.image = UIImage(named: "check_empty.png")
            } else if i2 == 1 {
                imgCheckBox1.image = UIImage(named: "checked.png")
            }
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yy"
            lblDate.text = df.string(from: event!.startDate)
            //  cell.endDate.text = df.string(from: event!.endDate)
            df.dateFormat = "HH:mm"
            lblStartTime.text = df.string(from: event!.startDate)
            lblEndTime.text = df.string(from: event!.endDate)
        }
        showDatePicker()
        showDatePickerDate()
        showDatePickerStartTime()
        showDatePickerEndTime()
        
        if isOld == 1{
            self.view.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            btnDelete.isHidden = true
        }
}
    
    @IBAction func onPickDateClicked(_ sender: Any) {
    }
    
    @IBAction func onStartTimeClicked(_ sender: Any) {
        
    }
    
    @IBAction func onEndTimeClicked(_ sender: Any) {
        
    }
    
    
    
    @IBAction func onConsumerClicked(_ sender: Any) {
        if i1 == 0 {
            imgCheckBox.image = UIImage(named: "checked.png")
            if i2 == 0{
                lblTypeOfService.text  = "Consumer Location"
            }
            else{
                lblTypeOfService.text  = "Consumer Location, Virtual"
            }
            i1 = 1
        } else if i1 == 1 {
            if i2 == 0{
                lblTypeOfService.text  = "None"
            }
            else{
                lblTypeOfService.text  = "Virtual"
            }
            imgCheckBox.image = UIImage(named: "check_empty.png")
            i1 = 0
        }
    }
    
    @IBAction func onRepeatClicked(_ sender: Any) {
        if repeatEnable == 0{
      //      repeatEnable = 1
        }
    }
    
    @IBAction func onVirtualClicked(_ sender: Any) {
        if i2 == 0 {
            if i1 == 0{
                lblTypeOfService.text  = "Virtual"
            }
            else{
                lblTypeOfService.text  = "Consumer Location, Virtual"
            }
            imgCheckBox1.image = UIImage(named: "checked.png")
            i2 = 1
        } else if i2 == 1 {
            if i1 == 0{
                lblTypeOfService.text  = "None"
            }
            else{
                lblTypeOfService.text  = "Consumer Location"
            }
            imgCheckBox1.image = UIImage(named: "check_empty.png")
            i2 = 0
        }
    }
    
    @IBAction func onExpandClicked(_ sender: Any) {
        if i == 0 {
            viewExtra.isHidden = false
            viewDistance.constant = 120
            i = 1
        } else if i == 1 {
            viewExtra.isHidden = true
            viewDistance.constant = 8
            i = 0
        }
    }
    
    @IBAction func onRepeatExpandClicked(_ sender: Any) {
        if iRepeat == 0 {
            viewRepeatExtra.isHidden = false
            iRepeat = 1
        } else if iRepeat == 1 {
            viewRepeatExtra.isHidden = true
            iRepeat = 0
        }
    }
    
    @IBAction func onRepeatTypeClicked(_ sender: Any) {
        
        let catePicker = ActionSheetStringPicker(title: "Repeat Type", rows: ["No Repeat","Daily","Weekly","Monthly","Yearly"], initialSelection: 0, doneBlock: {[unowned self] (picker, index, value)  -> Void in
            self.repeatEnable = index
            
            if index == 0{
                self.txtRepeatLastDate.isUserInteractionEnabled = false
                self.txtRepeatLastDate.placeholder = "Select Last Repeat Time"
            }
            else{
                self.txtRepeatLastDate.isUserInteractionEnabled = true
            }
            
            self.txtRepeatTime.text = self.myArray[index] as? String
            self.lblFrequency.text = self.myArray[index] as? String
            
            }, cancel: { (picker) -> Void in
                return
        }, origin: self.txtRepeatTime)
        
        catePicker?.show()
    }
    
    @IBAction func onRepeatLastDateClicked(_ sender: Any) {
        showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
        
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = +1
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.maximumDate = maxDate as Date
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtRepeatLastDate.inputAccessoryView = toolbar
        txtRepeatLastDate.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        txtRepeatLastDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    func showDatePickerDate(){
        //Formate Date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = +1
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.maximumDate = maxDate as Date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePickerDate));
        let spaceButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePickerDate));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDate.inputAccessoryView = toolbar
        txtDate.inputView = datePicker
    }
    
    @objc func donedatePickerDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        lblDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePickerDate(){
        self.view.endEditing(true)
    }
    
    func showDatePickerStartTime(){
        //Formate Date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = +1
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        datePicker.datePickerMode = .time
        datePicker.minimumDate = Date()
        datePicker.maximumDate = maxDate as Date
        datePicker.minuteInterval = 30
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePickerStartTime));
        let spaceButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePickerStartTime));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtStartTime.inputAccessoryView = toolbar
        txtStartTime.inputView = datePicker
    }
    
    @objc func donedatePickerStartTime(){
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        lblStartTime.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePickerStartTime(){
        self.view.endEditing(true)
    }
    
    func showDatePickerEndTime(){
        //Formate Date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = +1
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        datePicker.datePickerMode = .time
        datePicker.minimumDate = Date()
        datePicker.maximumDate = maxDate as Date
        datePicker.minuteInterval = 30
        datePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePickerEndTime));
        let spaceButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePickerEndTime));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtEndTime.inputAccessoryView = toolbar
        txtEndTime.inputView = datePicker
    }
    
    @objc func donedatePickerEndTime(){
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        lblEndTime.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePickerEndTime(){
        self.view.endEditing(true)
    }
    
    
    
    @objc func handleSave() {
        if lblTypeOfService.text == "None" {
            let alert = UIAlertController(title: "Alert", message: "Please Select Type Of Service", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            var stmt: OpaquePointer?
            
            let queryString = "INSERT INTO tblEvent (title, startTime, endTime, date, endDate, repeat) VALUES (?,?,?,?,?,?);"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let strService = lblTypeOfService.text! as NSString
            let strStartTime = lblStartTime.text! as NSString
            let strEndTime = lblEndTime.text! as NSString
            let strDate = lblDate.text! as NSString
            let strLastDate = txtRepeatLastDate.text! as NSString
            
            //binding the parameters
            if sqlite3_bind_text(stmt, 1, strService.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, strStartTime.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
    
            if sqlite3_bind_text(stmt, 3, strEndTime.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 4, strDate.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if repeatEnable == 0{
                if sqlite3_bind_text(stmt, 5, strDate.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
            }
            else{
                if sqlite3_bind_text(stmt, 5, strLastDate.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
            }
            
            if sqlite3_bind_int(stmt, 6, Int32(repeatEnable)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            
            event?.text = lblTypeOfService.text!
            EventManager.manager.fillDummyEvent()
            delegate?.eventDidSave() //Database work
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleUpdate() {
        if lblTypeOfService.text == "None" {
            let alert = UIAlertController(title: "Alert", message: "Please Select Type Of Service", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            var stmt: OpaquePointer?
            let queryString = "UPDATE tblEvent SET title = ?, startTime = ?, endTime = ?, date = ?, endDate = ?, repeat = ? WHERE id = ?;"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let strService = lblTypeOfService.text! as NSString
            let strStartTime = lblStartTime.text! as NSString
            let strEndTime = lblEndTime.text! as NSString
            let strDate = lblDate.text! as NSString
            let strLastDate = txtRepeatLastDate.text! as NSString
            
            //binding the parameters
            if sqlite3_bind_text(stmt, 1, strService.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, strStartTime.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, strEndTime.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 4, strDate.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if repeatEnable == 0{
                if sqlite3_bind_text(stmt, 5, strDate.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
            }
            else{
                if sqlite3_bind_text(stmt, 5, strLastDate.utf8String, -1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
            }
            
            if sqlite3_bind_int(stmt, 6, Int32(repeatEnable)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int(stmt, 7, Int32(EventID)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            
            EventManager.manager.fillDummyEvent()
            delegate?.eventDidUpdate()
            event?.text = lblTypeOfService.text!
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onDeleteClicked(_ sender: Any) {
        if lblTypeOfService.text == "None" {
            let alert = UIAlertController(title: "Alert", message: "Please Select Type Of Service", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            var stmt: OpaquePointer?
            let queryString = "DELETE FROM tblEvent WHERE id = ?;"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int(stmt, 1, Int32(EventID)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            
            EventManager.manager.fillDummyEvent()
            delegate?.eventDidUpdate()
            event?.text = lblTypeOfService.text!
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleCancel() {
        delegate?.eventDidCancel()
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        event?.text = textField.text!
    }
    
}
