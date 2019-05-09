//
//  Add_Event.swift
//  Calender_Event
//
//  Created by Harshil Patel on 4/12/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit

class Add_Event: UIViewController {

    @IBOutlet weak var txt_Event_Name: UITextField!
    @IBOutlet weak var txt_Event_Description: UITextField!
    @IBOutlet weak var txt_Event_Date: UITextField!
    @IBOutlet weak var txt_Homework_Status: UITextField!
    let datePicker = UIDatePicker()
    let Homework_Status_DropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Event"
        
        showDatePicker()
        
        self.txt_Homework_Status.text = "Select Status"
        self.Homework_Status_DropDown.anchorView = self.txt_Homework_Status
        self.Homework_Status_DropDown.dataSource = ["Upcoming","Past due","Completed"]
        self.Homework_Status_DropDown.selectionAction = { (index: Int, item: String) in
            
            self.txt_Homework_Status.text = item
           
        }
        
        let timestamp = NSDate().timeIntervalSince1970
        print(timestamp)
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.bordered, target: self, action: #selector(Add_Event.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.bordered, target: self, action: #selector(Add_Event.cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        txt_Event_Date.inputAccessoryView = toolbar
        // add datepicker to textField
        txt_Event_Date.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txt_Event_Date.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }

    @IBAction func btn_Add(_ sender: UIButton) {
        
        if self.txt_Event_Name.text == "" {
            
            showAlertViewWithText("Please Enter Event Name")
            return
            
        }
        
        if self.txt_Event_Description.text == "" {
            
            showAlertViewWithText("Please Enter Event Description")
            return
        }
        
        if self.txt_Event_Description.text == "" {
            
            showAlertViewWithText("Please Select Event Date")
            return
        }
        
        if self.txt_Homework_Status.text == "" || self.txt_Homework_Status.text == "Select Status" {
            
            showAlertViewWithText("Please Select Homework Status")
            return
        }
        
        if self.txt_Event_Date.text == "" {
            
            showAlertViewWithText("Please Select Date")
            return
        }
        
        
        let Event = NSMutableDictionary()
        Event.setValue(self.txt_Event_Name.text ?? "", forKey: "Event_name")
        Event.setValue(self.txt_Event_Description.text ?? "", forKey: "Event_description")
        Event.setValue(self.txt_Event_Date.text ?? "", forKey: "Event_date")
        Event.setValue(self.txt_Homework_Status.text ?? "", forKey: "Status")
        Event_data.add(Event)
        UserDefaults.standard.set(Event_data, forKey: "Event_data")
       self.scheduleNotification(Event_Name: self.txt_Event_Name.text ?? "", Event_Status: self.txt_Homework_Status.text ?? "",Data: Event)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func scheduleNotification(Event_Name: String,Event_Status:String,Data:NSDictionary) {
        
//        let content = UNMutableNotificationContent()
//
//        content.title = notificationType
//        content.body = notificationType
//        content.sound = UNNotificationSound.default

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let Event_date = formatter.date(from: txt_Event_Date.text ?? "")
        let twelHourAgo = Calendar.current.date(byAdding: .hour, value: -12, to: Event_date!)
        
        let notification = UILocalNotification()
        notification.timeZone = NSTimeZone.default
        notification.fireDate = twelHourAgo
        notification.alertBody = Event_Status
        notification.alertTitle = Event_Name
        notification.userInfo = (Data as! [AnyHashable : Any])
        notification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.scheduleLocalNotification(notification)
        
//        let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second,], from: twelHourAgo!)
        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: false)
//        let identifier = "Local Notification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { (error) in
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//            }
//        }
        
        
        
    }
    
    func showAlertViewWithText(_ text: String)  {
        
        let alert = UIAlertController(title: text, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

}

extension Add_Event:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txt_Homework_Status {
            self.view.endEditing(true)
            self.Homework_Status_DropDown.show()
            return false
        } else {
            return true
        }
    }
}
