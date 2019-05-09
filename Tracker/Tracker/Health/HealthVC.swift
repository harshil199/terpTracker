//
//  Health.swift
//  Tracker
//
//  Created by Rushad Antia on 4/12/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//
import UIKit
import Foundation
import HealthKit
import Charts

class HealthVC: UIViewController {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var stepGoalLabel: UILabel!
    @IBOutlet weak var sleepGoalLabel: UILabel!
    @IBOutlet weak var stepPBar: UIProgressView!
    @IBOutlet weak var sleepPBar: UIProgressView!
    
    @IBOutlet weak var sleepChartView: BarChartView!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    private var stepGoal = 1
    private var bcDataEntry: [BarChartDataEntry] = []
    private var sleepDataEntry: [BarChartDataEntry] = []
    private let notifPub = notifcationPublisher()
    private var loaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load data upn loading the view
        loadData()
        
    }
    
    func loadData(){
        
        let firstTime = UserDefaults.standard.bool(forKey: "firstTime")
        
        //if its the firsttime setup
        if !firstTime {
            performSegue(withIdentifier: "profileSegID", sender: nil)
            UserDefaults.standard.set(true, forKey: "firstTime")
        }
        
        //get the users name
        let userName = UserDefaults.standard.string(forKey: "healthUserName")
        
        //set the titles of everything based on if they exist or not
        titleBar.title = (userName == nil ? "Setup your user profile ->" : userName)
        
        welcomeLabel.text = (userName == nil ? "  Welcome!" : " Welcome \(userName!)!")
        
        //update the step goal if it exists
        self.stepGoal = Int(UserDefaults.standard.string(forKey: "healthStepGoal") ?? "1") ?? -1
        
        //set profile button to male or female depending on the what is known in health kit
        do {
            let userAgeSexAndBloodType = try HKDataManager.getAgeSexBloodType()
            
            switch userAgeSexAndBloodType.bioSex {
            case .female: self.profileButton.title = "👩🏻"
            case .male: self.profileButton.title = "👨🏼"
            default: self.profileButton.title = "Edit"
                
            }
            
        } catch let error {
            print("err: \(error.localizedDescription)")
            
        }
        
        //set the data source to the array of data entries
        let bcDataSet = BarChartDataSet(values: self.bcDataEntry , label: "Steps Taken")
        bcDataSet.colors = [UIColor.red]
        let barChartData = BarChartData(dataSet: bcDataSet)
        
        //set grindlines to nothing
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        
        //no zoom
        barChartView.isUserInteractionEnabled = false
        
        //make numbers ints
        self.barChartView.noDataText = "You haven't walked this week :/"
        self.barChartView.data = barChartData
        self.barChartView.xAxis.granularity = 1
        
        //make sure to update the progressbar
        HKDataManager.getSteps(completion:  { (steps) in
            DispatchQueue.main.async {
                
                self.stepGoalLabel.text = "Daily Step Goal: \(Int(steps))/\(self.stepGoal)"
                self.stepPBar.progress = Float(steps/(self.stepGoal != 0 ? Double(self.stepGoal) : 1))
                self.stepPBar.layer.borderColor  = UIColor.blue.cgColor
                self.stepPBar.layer.borderWidth = 0.3
                
                
                if self.loaded == true {
                    if Int(steps) <= 6000 {
                        print("HI")
                        
                        self.notifPub.sendNotifcation(title: "Road to 10k!", subtitle: "Try to get 10k steps", body: "You've only walked \(steps) steps today!", badge: nil, delayInterval: nil)
                        
                    }
                    self.loaded = false
                }
                
            }
        })
        
        //import the data into the graph
        //we can send the view into the param but thats
        //the model accessing the view which is bad
        importStepsHistoryOneWeek()
        
        importSleepHistoryOneWeek()
    }
    
    //loads one week of data into the view
    //Source: https://stackoverflow.com/questions/50620547/how-to-get-apple-health-data-by-date-wise
    func importStepsHistoryOneWeek() {
        let healthStore = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        //get a week's worth of data
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        //set the interval to a 1 day interval
        var interval = DateComponents()
        interval.day = 1
        
        //get the other parts of the date
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        //create a query for health kit
        let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate, intervalComponents: interval)
        
        //get the initial results from the callback
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                print("ERROR")
                return
            }
            var day = 1
            
            //go through all of the data
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                
                //get the steps from the data
                if let sum = statistics.sumQuantity() {
                    
                    //add the data to the graph
                    let steps = sum.doubleValue(for: HKUnit.count())
                    self.bcDataEntry.append(BarChartDataEntry(x: Double(day), y: steps))
                    
                    //  print("Amount of steps: \(steps), date: \(statistics.startDate)")
                    day = day + 1
                }
            }
        }
        
        //execute the query
        healthStore.execute(query)
    }
    
    //ty https://www.appcoda.com/sleep-analysis-healthkit/
    func importSleepHistoryOneWeek() {
        
        //set the data source to the array of data entries
        let bcDataSet = BarChartDataSet(values: self.sleepDataEntry , label: "Hours Slept")
        bcDataSet.colors = [UIColor.purple]
        let barChartData = BarChartData(dataSet: bcDataSet)
        
        //set grindlines to nothing
        sleepChartView.leftAxis.drawAxisLineEnabled = false
        sleepChartView.leftAxis.drawGridLinesEnabled = false
        sleepChartView.leftAxis.drawLabelsEnabled = false
        
        sleepChartView.rightAxis.drawGridLinesEnabled = false
        sleepChartView.rightAxis.drawAxisLineEnabled = false
        
        //no zoom
        sleepChartView.isUserInteractionEnabled = false
        
        //make numbers ints
        self.sleepChartView.noDataText = "Try getting some sleep bud :)"
        self.sleepChartView.data = barChartData
        self.sleepChartView.xAxis.granularity = 1
        self.sleepChartView.legend.textColor = UIColor.purple
        
        
        let healthStore = HKHealthStore()
        
        var meanSleep = 0.0
        var numSamples = 0.0
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis){
            
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 7, sortDescriptors: [sort]){  (query, tmpResult, error) -> Void in
                
                if error != nil {
                    return
                }
                
                if let result = tmpResult {
                    
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = sample.endDate.timeIntervalSince(sample.startDate) //time slept in hours
                            
                            meanSleep = meanSleep + Double(value)/60/60.0
                            numSamples = numSamples + 1
                            self.sleepDataEntry.append(BarChartDataEntry(x: Double(numSamples), y: (Double(value)/60/60.0)))
                            //   print("V: \(value) MS: \(meanSleep) NS: \(numSamples)")
                        }
                    }
                    if numSamples != 0 {
                        if let sleepGoal =   UserDefaults.standard.string(forKey: "healthSleepGoal"){
                            DispatchQueue.main.async {
                                self.sleepGoalLabel.text = "Average Sleep \(Int(Double(meanSleep/numSamples)))/\(sleepGoal)"
                                self.sleepPBar.progress = Float((meanSleep/numSamples)/Double(sleepGoal)!)
                                self.sleepPBar.layer.borderColor  = UIColor.purple.cgColor
                                self.sleepPBar.layer.borderWidth = 0.3
                                self.sleepChartView.data?.notifyDataChanged()
                                self.sleepChartView.notifyDataSetChanged()
                            }
                        }
                    }
                }
            }
            healthStore.execute(query)
        }
    }
    
    //reload on closing so that it so fresh when it comes back
    override func viewWillDisappear(_ animated: Bool) {
        loadData()
    }
    
    //when the view is to the front the data]
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        barChartView.data?.notifyDataChanged()
        barChartView.notifyDataSetChanged()
        sleepChartView.data?.notifyDataChanged()
        sleepChartView.notifyDataSetChanged()
    }
    
    
}
