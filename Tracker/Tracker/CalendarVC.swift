//
//  CalendarVC.swift
//  Tracker
//
//  Created by Rushad Antia on 4/12/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import LocalAuthentication

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: JKCalendar!
    @IBOutlet weak var tbl_Event: UITableView!
    @IBOutlet weak var lbl_Selec_Date: UILabel!
    @IBOutlet weak var lbl_No_Events: UILabel!
    
    
    @IBAction func addButtonAction(_ sender: Any) {
        
        let addViewControl = storyboard?.instantiateViewController(withIdentifier: "addView") as! addHomeworkViewController
        present(addViewControl, animated: true, completion: nil)
    }
    
    var selectDay: JKDay = JKDay(date: Date())
    let markColor = UIColor(red: 40/255, green: 178/255, blue: 253/255, alpha: 1)
    var Event_Days = [JKDay]()
    
    var is_HW = false
    var Event_Title = [String]()
    var Event_Status = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.textColor = UIColor(white: 0.25, alpha: 1)
        calendar.backgroundColor = UIColor.white
        
        calendar.isNearbyMonthNameDisplayed = false
        calendar.isScrollEnabled = false
        
        let testDay = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let Event_date = formatter.string(from: testDay)
        print(Event_date)
        self.lbl_Selec_Date.text = Event_date
        
        tbl_Event.register(UINib(nibName: "Event_Cell", bundle: nil), forCellReuseIdentifier: "Event_Cell")
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.Event_Status.removeAll()
        self.Event_Title.removeAll()
        
        self.HW()
        
        for i in 0..<Event_data.count {
            
            let dic = Event_data[i] as! NSDictionary
            let date = dic.value(forKey: "Event_date") as! String
            print("Event_date",date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let Event_date = formatter.date(from: date)
            Event_Days.append(JKDay(date: Event_date!))
            
        }
        calendar.reloadData()
        
        self.tbl_Event.tableFooterView = UIView()
        
        for i in 0..<Event_data.count {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let testDay = formatter.string(from: selectDay.date)
            
            let dic = Event_data[i] as! NSDictionary
            let Event_date = dic.value(forKey: "Event_date") as! String
            if testDay == Event_date {
                self.Event_Title.append((dic.value(forKey: "Event_name") as! String) + " - Event")
                self.Event_Status.append(dic.value(forKey: "Status") as! String)
                self.tbl_Event.reloadData()
                self.lbl_No_Events.isHidden = true
                self.tbl_Event.isHidden = false
            } else {
                if !is_HW {
                    print("Empty")
                    self.lbl_No_Events.isHidden = false
                    self.tbl_Event.isHidden = true
                }
            }
        }
        
        
    }
    
}


extension CalendarVC: JKCalendarDelegate{
    
    func calendar(_ calendar: JKCalendar, didTouch day: JKDay){
        
        self.Event_Status.removeAll()
        self.Event_Title.removeAll()
        
        selectDay = day
        calendar.focusWeek = day < calendar.month ? 0: day > calendar.month ? calendar.month.weeksCount - 1: day.weekOfMonth - 1
        calendar.reloadData()
        
        let testDay = JKDay(date: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let Event_date = formatter.string(from: min(day, testDay).date)
        print(Event_date)
        self.lbl_Selec_Date.text = Event_date
        
        self.HW()
        
        for i in 0..<Event_data.count {
            
            let dic = Event_data[i] as! NSDictionary
            let date = dic.value(forKey: "Event_date") as! String
            if date == Event_date {
                self.Event_Title.append((dic.value(forKey: "Event_name") as! String) + " - Event")
                self.Event_Status.append(dic.value(forKey: "Status") as! String)
                self.tbl_Event.reloadData()
                self.lbl_No_Events.isHidden = true
                self.tbl_Event.isHidden = false
            } else {
                if !is_HW {
                    print("Empty")
                    self.lbl_No_Events.isHidden = false
                    self.tbl_Event.isHidden = true
                }
            }
        }
        
        
    }
    
    func HW() {
        var found = false
        let fetchData : NSFetchRequest<HWEntry> = HWEntry.fetchRequest()
        do{
            let arr1 = try PersistenceService.context.fetch(fetchData)
            
            print(arr1.count)
            
            if(!arr1.isEmpty){
                for i in 0...arr1.count - 1{
                    let name = arr1[i].taskName!
                    let date = arr1[i].dueDate!
                    let dateformatter = DateFormatter()
                    let rDate = date.replacingOccurrences(of: "at", with: "-")
                    dateformatter.dateFormat = "MMM dd, yyyy - hh:mm a"
                    
                    
                    let HWD_date = dateformatter.date(from: rDate) ?? Date.init()
                    
                    
                    let HW_date_STR = dateformatter.string(from: HWD_date)
                    
                    let replacedDate = HW_date_STR.replacingOccurrences(of: "at", with: "-")
                    //
                    //                    var status = String()
                    //                    if(arr1[i].isDone == true){
                    //
                    //                        status = "Completed"
                    //                    }else{
                    //                        status = "Upcoming"
                    //                    }
                    //
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "dd/MM/yyyy"
                    let HWDay = formatter1.string(from: HWD_date)
                    
                    let formatter2 = DateFormatter()
                    formatter2.dateFormat = "dd/MM/yyyy"
                    let testDay = formatter2.string(from: selectDay.date)
                    
                    let HW_date = HWDay
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    let Event_date = formatter.date(from: HW_date)
                    Event_Days.append(JKDay(date: Event_date!))
                    
                    if testDay == HWDay {
                    
                        self.Event_Title.append((name) + " - Home Work")
                        self.Event_Status.append("Due By : " + replacedDate)
                        self.lbl_No_Events.isHidden = true
                        self.tbl_Event.isHidden = false
                        self.is_HW = true
                        self.tbl_Event.reloadData()
                        self.calendar.reloadData()
                        found = true
                    } else if(found == false) {
                        self.lbl_No_Events.isHidden = false
                        self.tbl_Event.isHidden = true
                        self.is_HW = false
                    }
                }
            }
        } catch {
            
        }
    }
}

extension CalendarVC: JKCalendarDataSource{
    
    func calendar(_ calendar: JKCalendar, marksWith month: JKMonth) -> [JKCalendarMark]? {
        
        let firstMarkDay: [JKDay] = Event_Days //JKDay(year: 2018, month: 1, day: 9)!
        
        
        var marks: [JKCalendarMark] = []
        if selectDay == month{
            marks.append(JKCalendarMark(type: .circle,
                                        day: selectDay,
                                        color: markColor))
        }
        
        for i in 0..<firstMarkDay.count {
            
            let mark_day = firstMarkDay[i]
            marks.append(JKCalendarMark(type: .underline,
                                        day: mark_day,
                                        color: markColor))
        }
        
        
        
        
        return marks
    }
    
    func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?{
        let startDay: JKDay = JKDay(year: 2018, month: 1, day: 17)!
        let endDay: JKDay = JKDay(year: 2018, month: 1, day: 18)!
        
        return [JKCalendarContinuousMark(type: .dot,
                                         start: startDay,
                                         end: endDay,
                                         color: markColor)]
    }
    
}

extension CalendarVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Event_Title.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : Event_Cell = tableView.dequeueReusableCell(withIdentifier: "Event_Cell", for: indexPath) as! Event_Cell
        
        cell.lbl_Event_Name.text = self.Event_Title[indexPath.row]
        cell.lbl_Event_Status.text = self.Event_Status[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
}
