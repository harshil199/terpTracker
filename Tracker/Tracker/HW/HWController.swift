//
//  HWController.swift
//  Tracker
//
//  Created by Harshil Patel on 4/20/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class HWController : UITableViewController,UISearchBarDelegate,UISearchResultsUpdating {
    var notifcationShown = false
    private let notificationManger = notifcationPublisher()
    let searchController = UISearchController(searchResultsController: nil)
    var temp = HWData()
    
    var taskData = HWData()
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    @IBAction func editAction(_ sender: Any) {
        if let name = UserDefaults.standard.value(forKey: "editName") as? String{
            if let date = UserDefaults.standard.value(forKey: "editDate") as? String{
                let addViewControl = storyboard?.instantiateViewController(withIdentifier: "addView") as! addHomeworkViewController
                present(addViewControl, animated: true, completion: nil)
            }
            
        }else{
            displayAlertMessage(message: "Select a Task to edit")
            
        }
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "editName")
        UserDefaults.standard.removeObject(forKey: "editDate")
        UserDefaults.standard.removeObject(forKey: "row")
        UserDefaults.standard.removeObject(forKey: "section")
        
        UserDefaults.standard.synchronize()
        let addViewControl = storyboard?.instantiateViewController(withIdentifier: "addView") as! addHomeworkViewController
        present(addViewControl, animated: true, completion: nil)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        saveData()
    }
    
    func displayAlertMessage(message: String){
        let myAlert = UIAlertController(title: "Cell Not Selected", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        myAlert.addAction(okAction);
        present(myAlert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        UserDefaults.standard.removeObject(forKey: "assignName")
        //        UserDefaults.standard.removeObject(forKey: "dueDate")
        
        //        UserDefaults.standard.removeObject(forKey: "editName")
        //        UserDefaults.standard.removeObject(forKey: "editDate")
        //        UserDefaults.standard.removeObject(forKey: "row")
        //        UserDefaults.standard.removeObject(forKey: "section")
        //
        //        UserDefaults.standard.synchronize()
        
//        if (notifcationShown == true){
        addAction()
        checkPastDue()
        checkForUpcoming()
        saveData()
//        }
        
        
    }
    
    func getNotifications(){
        var past = taskData.tasks[0].count
        var upcoming = taskData.tasks[1].count
        var body = ""
        var title = "Alert"
        var subtitle = ""

        if(past != 0  && upcoming != 0 ){
            subtitle = "You have Overdue and Upcoming Tasks"
            body = "Past Tasks:"+String(past)+" Upcoming Tasks:"+String(upcoming)
        }else if (past != 0 && upcoming == 0){
            subtitle = "You have Overdue Tasks"
            
            body = "Past Tasks:"+String(past)
        }
        else if(upcoming != 0 && past == 0){
            subtitle = "You have Upcoming Tasks"
            body = "Upcoming Tasks:"+String(upcoming)
        }
        if(past != 0  || upcoming != 0 ){
    notificationManger.sendNotifcation(title: title, subtitle: subtitle, body: body, badge: nil, delayInterval: nil)
        }
        
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.addSubview(blurEffectView)
        
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Authenticate"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {(success, error) in
                
                if success {
                    DispatchQueue.main.async {
                        blurEffectView.removeFromSuperview()
                    }
                    
                    self.addAction()
                    self.checkPastDue()
                    self.checkForUpcoming()
                    self.saveData()
                    self.getNotifications()
                }
                
            })
        }
            
        else {
            showAlertController("Touch ID not available")
        }
        
        UserDefaults.standard.removeObject(forKey: "assignName")
        UserDefaults.standard.removeObject(forKey: "dueDate")
        
        UserDefaults.standard.removeObject(forKey: "editName")
        UserDefaults.standard.removeObject(forKey: "editDate")
        UserDefaults.standard.removeObject(forKey: "row")
        UserDefaults.standard.removeObject(forKey: "section")
        
        UserDefaults.standard.synchronize()
        
        
        fetchData()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.allowsSelection = true
        searchController.searchBar.delegate = self
       
//        notifcationShown = true;
        
    }
    func fetchUpdate()-> [HWTask]{
        let fetchData : NSFetchRequest<HWEntry> = HWEntry.fetchRequest()
        var ret = [HWTask]()
        do{
            let arr1 = try PersistenceService.context.fetch(fetchData)
            if(!arr1.isEmpty){
                for i in 0...arr1.count - 1{
                    let name = arr1[i].taskName!
                    let date = arr1[i].dueDate!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    let replacedDate = date.replacingOccurrences(of: "at", with: "-")
                    
                    
                    
                    let timestamp = dateFormatter.date(from: replacedDate) ?? Date.init()
                    
                    let newTask = HWTask(name: name ,timeDue: replacedDate,timeStamp: timestamp, isDone: arr1[i].isDone)
                    
                    ret.append(newTask)
                }
                
            }
            
        }catch{
            
        }
        return ret
    }
    func fetchData (){
        taskData.tasks[0] = [HWTask]()
        taskData.tasks[1] = [HWTask]()
        taskData.tasks[2] = [HWTask]()
        taskData.tasks[3] = [HWTask]()
        taskData.tasks[4] = [HWTask]()
        
        let fetchData : NSFetchRequest<HWEntry> = HWEntry.fetchRequest()
        do{
            let arr1 = try PersistenceService.context.fetch(fetchData)
            if(!arr1.isEmpty){
                for i in 0...arr1.count - 1{
                    let name = arr1[i].taskName!
                    let date = arr1[i].dueDate!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    let replacedDate = date.replacingOccurrences(of: "at", with: "-")
                    
                    
                    
                    let timestamp = dateFormatter.date(from: replacedDate) ?? Date.init()
                    
                    let newTask = HWTask(name: name ,timeDue: replacedDate,timeStamp: timestamp, isDone: arr1[i].isDone)
                    if(arr1[i].isDone == true){
                        taskData.add(newTask, at: 0, section: 3)
                        
                    }else{
                        taskData.add(newTask, at: 0, section: 2)
                    }
                }
            }
            
        }catch{
            
        }
    }
    func checkForUpcoming(){
        let daysToAdd = 7
        let currentDate = Date()
        
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        
        for i in (0 ..< self.taskData.tasks[0].count).reversed() {
            if self.taskData.tasks[0][i].date.timeStamp < futureDate! && self.taskData.tasks[0][i].date.timeStamp > currentDate{
                
                let toInsert = self.taskData.tasks[0][i]
                self.taskData.add(toInsert, at: 0, section: 1)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                self.taskData.remove(at: i, section: 0)
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            }
        }
        for i in (0 ..< self.taskData.tasks[2].count).reversed() {
            
            if self.taskData.tasks[2][i].date.timeStamp < futureDate! && self.taskData.tasks[2][i].date.timeStamp > currentDate{
                
                let toInsert = self.taskData.tasks[2][i]
                self.taskData.add(toInsert, at: 0, section: 1)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                self.taskData.remove(at: i, section: 2)
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 2)], with: .automatic)
            }
        }
        for i in (0 ..< self.taskData.tasks[1].count).reversed() {
            if self.taskData.tasks[1][i].date.timeStamp > futureDate! {
                
                let toInsert = self.taskData.tasks[1][i]
                self.taskData.add(toInsert, at: 0, section: 2)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                self.taskData.remove(at: i, section: 1)
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
            }
        }
        tableView.reloadData();
        checkPastDue()
        
    }
    
    
    
    
    func checkPastDue(){
        let today = Date.init()
        for j in 1...2 {
            for i in (0 ..< self.taskData.tasks[j].count).reversed() {
                if self.taskData.tasks[j][i].date.timeStamp < today {
                    let toInsert = self.taskData.tasks[j][i]
                    self.taskData.add(toInsert, at: 0, section: 0)
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.taskData.remove(at: i, section: j)
                    self.tableView.deleteRows(at: [IndexPath(row: i, section: j)], with: .automatic)
                    
                }
            }
            
        }
        
        for i in (0 ..< self.taskData.tasks[0].count).reversed() {
            if self.taskData.tasks[0][i].date.timeStamp > today {
                let toInsert = self.taskData.tasks[0][i]
                self.taskData.add(toInsert, at: 0, section: 2)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                self.taskData.remove(at: i, section: 0)
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                
            }
        }
        tableView.reloadData();
    }
    
    func saveData(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HWEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try PersistenceService.context.persistentStoreCoordinator!.execute(deleteRequest, with: PersistenceService.context)
        } catch let error as NSError {
            // TODO: handle the error
        }
        var arr = taskData.tasks[0]+taskData.tasks[1]+taskData.tasks[2]+taskData.tasks[3]
        if(!arr.isEmpty){
            for i in 0...arr.count - 1 {
                let toSave = HWEntry(context: PersistenceService.context)
                toSave.taskName = arr[i].taskName
                toSave.dueDate = arr[i].date.date
                toSave.isDone = arr[i].isDone
                PersistenceService.saveContext()
                
                //        let toSave = DataArray(context: PersistenceService.context)
                //        toSave.past = taskData.tasks[0]
                //        toSave.upcoming = taskData.tasks[1]
                //        toSave.todo = taskData.tasks[2]
                //        toSave.completed = taskData.tasks[3]
                //        PersistenceService.saveContext()
                
            }
        }
    }
    func addAction() {
        
        if let name = UserDefaults.standard.value(forKey: "assignName") as? String{
            if let date = UserDefaults.standard.value(forKey: "dueDate") as? String{
                UserDefaults.standard.removeObject(forKey: "assignName")
                UserDefaults.standard.removeObject(forKey: "dueDate")
                UserDefaults.standard.synchronize()
                
                //        let todoTasks = Todo(context: PersistenceService.context)
                //        let todoTasks = TodoData(context: PersistenceService.context)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
                dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                
                let replacedDate = date.replacingOccurrences(of: "at", with: "-")
                
                let timestamp = dateFormatter.date(from: replacedDate) ?? Date.init()
                
                let newTask = HWTask(name: name ,timeDue: date,timeStamp: timestamp)
                
                
                self.taskData.add(newTask, at: 0,section: 2)
                let indexPath = IndexPath(row: 0, section: 2)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.taskData.tasks[2].sort(by: {$0.date.timeStamp > $1.date.timeStamp})
                
                tableView.reloadData();
            }
        } else if let name = UserDefaults.standard.value(forKey: "editName") as? String{
            if let date = UserDefaults.standard.value(forKey: "editDate") as? String{
                if  let indexRow = UserDefaults.standard.value(forKey: "row") as? Int {
                    if let indexSection = UserDefaults.standard.value(forKey: "section") as? Int {
                        UserDefaults.standard.removeObject(forKey: "editName")
                        UserDefaults.standard.removeObject(forKey: "editDate")
                        UserDefaults.standard.removeObject(forKey: "row")
                        UserDefaults.standard.removeObject(forKey: "section")
                        UserDefaults.standard.synchronize()
                        let index = IndexPath(row: indexRow , section: indexSection)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
                        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                        
                        let replacedDate = date.replacingOccurrences(of: "at", with: "-")
                        
                        let timestamp = dateFormatter.date(from: replacedDate) ?? Date.init()
                        
                        let newTask = HWTask(name: name ,timeDue: date,timeStamp: timestamp)
                        taskData.tasks[indexSection][indexRow] = newTask
                        
                        if let cell = tableView.cellForRow(at: index) as? customTableViewCell{
                            cell.setLabels(name: name, date: date)
                        }
                    }
                }
            }
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            
            //            if(arr.isEmpty){
            //                arr = temp.tasks[4]
            //            }
            var toDelete = [IndexPath]()
            var toAdd = [IndexPath]()
            
            for i in 0...4 {
                if(taskData.tasks[i].count != 0){
                    for j in 0...taskData.tasks[i].count - 1 {
                        toDelete.append(IndexPath(row: j, section: i))
                    }
                }
            }
            
            taskData.tasks[0] = [HWTask]()
            taskData.tasks[1] = [HWTask]()
            taskData.tasks[2] = [HWTask]()
            taskData.tasks[3] = [HWTask]()
            taskData.tasks[4] = [HWTask]()
            
            tableView.deleteRows(at: toDelete, with: .automatic)
            tableView.reloadData()
            
            
            let arr = fetchUpdate()
            taskData.tasks[4] = arr
            if(arr.count != 0){
                for j in 0...arr.count - 1 {
                    toAdd.append(IndexPath(row: j, section: 4))
                }
            }
            
            
            tableView.insertRows(at: toAdd, with: .automatic)
            tableView.reloadData()
            
        }
        //        else {
        //            updateSearchResults(for: <#T##UISearchController#>)
        //        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        var toDelete = [IndexPath]()
        var toAdd = [IndexPath]()
        
        for i in 0...4 {
            if(taskData.tasks[i].count != 0){
                for j in 0...taskData.tasks[i].count - 1 {
                    toDelete.append(IndexPath(row: j, section: i))
                }
            }
        }
        taskData.tasks[0] = [HWTask]()
        taskData.tasks[1] = [HWTask]()
        taskData.tasks[2] = [HWTask]()
        taskData.tasks[3] = [HWTask]()
        taskData.tasks[4] = [HWTask]()
        
        tableView.deleteRows(at: toDelete, with: .automatic)
        fetchData()
        for i in 0...4 {
            if(taskData.tasks[i].count != 0){
                for j in 0...taskData.tasks[i].count - 1 {
                    toAdd.append(IndexPath(row: j, section: i))
                }
            }
        }
        tableView.insertRows(at: toAdd, with: .automatic)
        
        tableView.reloadData()
        
        checkPastDue()
        checkForUpcoming()
        
        //        var toDelete = [IndexPath]()
        //        var toAdd = [IndexPath]()
        //
        //
        //        for j in 0...4{
        //            if(taskData.tasks[j].count != 0 ){
        //                for i in 0...taskData.tasks[j].count - 1 {
        //                    toDelete.append(IndexPath(row: i, section: j))
        //                }
        //                taskData.tasks[j] = [HWTask]()
        //            }
        //        }
        //
        //        tableView.deleteRows(at: toDelete, with: .automatic)
        //
        //
        //
        //
        //        for i in 0...3{
        //            self.taskData.tasks[i] = temp.tasks[i]
        //        }
        //
        //        for i in 0...3 {
        //            if(taskData.tasks[i].count != 0){
        //                for j in 0...taskData.tasks[i].count - 1 {
        //                    toAdd.append(IndexPath(row: j, section: i))
        //                }
        //            }
        //        }
        //        if(!toAdd.isEmpty){
        //            tableView.insertRows(at: toAdd, with: .automatic)
        //        }
        
        
        searchBar.text = nil
        searchBar.showsCancelButton = false
        
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController){
        //        if(searchController.searchBar.text! == ""){
        //            let arr = taskData.tasks[0]+taskData.tasks[1]+taskData.tasks[2]+taskData.tasks[3]
        //            var toDelete = [IndexPath]()
        //            var toAdd = [IndexPath]()
        //
        //            for i in 0...3 {
        //                if(taskData.tasks[i].count != 0){
        //                    for j in 0...taskData.tasks[i].count - 1 {
        //                        toDelete.append(IndexPath(row: j, section: i))
        //                    }
        //                }
        //            }
        //
        //            taskData.tasks[0] = [HWTask]()
        //            taskData.tasks[1] = [HWTask]()
        //            taskData.tasks[2] = [HWTask]()
        //            taskData.tasks[3] = [HWTask]()
        //
        //            tableView.deleteRows(at: toDelete, with: .automatic)
        //
        //            taskData.tasks[4] = arr
        //            if(arr.count != 0){
        //                for j in 0...arr.count - 1 {
        //                    toAdd.append(IndexPath(row: j, section: 4))
        //                }
        //            }
        //
        //
        //            tableView.insertRows(at: toAdd, with: .automatic)
        //            tableView.reloadData()
        //
        //
        //        }
        
        
        
        if(searchController.searchBar.text! != ""){
            var filterTasks = [HWTask]()
            for i in 0...4{
                temp.tasks[i] = self.taskData.tasks[i]
            }
            let arr = taskData.tasks[0]+taskData.tasks[1]+taskData.tasks[2]+taskData.tasks[3]+taskData.tasks[4]
            if(arr.count != 0){
                for k in 0...arr.count - 1 {
                    if (arr[k].taskName.lowercased().contains(searchController.searchBar.text!.lowercased())){
                        filterTasks.append(arr[k])
                    }
                }
            }
            var toDelete = [IndexPath]()
            var toAdd = [IndexPath]()
            
            for i in 0...4 {
                if(taskData.tasks[i].count != 0){
                    for j in 0...taskData.tasks[i].count - 1 {
                        toDelete.append(IndexPath(row: j, section: i))
                    }
                }
            }
            
            taskData.tasks[0] = [HWTask]()
            taskData.tasks[1] = [HWTask]()
            taskData.tasks[2] = [HWTask]()
            taskData.tasks[3] = [HWTask]()
            taskData.tasks[4] = [HWTask]()
            
            tableView.deleteRows(at: toDelete, with: .automatic)
            
            
            
            taskData.tasks[4] = filterTasks
            if(filterTasks.count != 0){
                for j in 0...filterTasks.count - 1 {
                    toAdd.append(IndexPath(row: j, section: 4))
                }
            }
            
            temp.tasks[4] = filterTasks
            tableView.insertRows(at: toAdd, with: .automatic)
        }
        tableView.reloadData()
        
    }
    
    
    
    
    
}
// MARK: - DataSource

extension HWController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            UserDefaults.standard.removeObject(forKey: "editName")
            UserDefaults.standard.removeObject(forKey: "editDate")
            UserDefaults.standard.synchronize()
            
            return nil
        }
        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        switch section {
        case 0:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return "Past - Tasks:" + String(self.tableView(tableView, numberOfRowsInSection: section))
            }
        case 1:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return "Upcoming - Tasks:" + String(self.tableView(tableView, numberOfRowsInSection: section))
            }
        case 2:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return "To Do - Tasks:" + String(self.tableView(tableView, numberOfRowsInSection: section))
            }
        case 3:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return "Completed - Tasks:" + String(self.tableView(tableView, numberOfRowsInSection: section))
            }
        case 4:
            if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                return "Search Results - Tasks:" + String(self.tableView(tableView, numberOfRowsInSection: section))
            }
        default:
            return nil
            
        }
        return nil;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskData.tasks.count
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return taskData.tasks[section].count;
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customTableViewCell
        let taskName = taskData.tasks[indexPath.section][indexPath.row].taskName
        let taskDueDate = "Due By:  "+taskData.tasks[indexPath.section][indexPath.row].date.date
        cell.setLabels(name: taskName, date: taskDueDate)
        return cell
        
    }
    
    // MARK: - DataSource
    
}

extension HWController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(self.taskData.tasks[section].count == 0){
            return CGFloat.leastNonzeroMagnitude
        }else {
            return 70
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(taskData.tasks[indexPath.section][indexPath.row].taskName, forKey: "editName")
        UserDefaults.standard.set(taskData.tasks[indexPath.section][indexPath.row].date.date, forKey: "editDate")
        UserDefaults.standard.set(indexPath.section, forKey: "section")
        UserDefaults.standard.set(indexPath.row, forKey: "row")
        UserDefaults.standard.synchronize()
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            self.taskData.tasks[indexPath.section][indexPath.row].isDone = true
            
            let doneTask = self.taskData.remove(at: indexPath.row,section: indexPath.section)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.taskData.add(doneTask,at: 0, section: 3, isDone: true)
            
            tableView.insertRows(at: [IndexPath(row: 0, section: 3)], with: .automatic)
            tableView.reloadData()
            completionHandler(true)
            
            
        }
        let doneImage = #imageLiteral(resourceName: "done")
        doneAction.image = doneImage;
        doneAction.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        return UISwipeActionsConfiguration(actions: [doneAction])
        
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive , title: nil) { (action, sourceView, completionHandler) in
            
            let isDone = self.taskData.tasks[indexPath.section][indexPath.row].isDone
            
            self.taskData.remove(at: indexPath.row,section: indexPath.section ,isDone: isDone)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            completionHandler(true)
        }
        
        
        let deleteImage = #imageLiteral(resourceName: "delete")
        deleteAction.image = deleteImage
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

