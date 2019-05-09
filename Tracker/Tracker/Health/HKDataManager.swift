//
//  HKDataManager.swift
//  Tracker
//
//  Created by Rushad Antia on 4/18/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import Foundation
import HealthKit


class HKDataManager {
    
    
    class func getAgeSexBloodType() throws -> (age: Int, bioSex: HKBiologicalSex, bloodType: HKBloodType){
        
        let store = HKHealthStore()
        
        do{
            
            //1. This method throws an error if these data are not available.
            let birthdayComponents = try store.dateOfBirthComponents()
            let biologicalSex = try store.biologicalSex()
            let bloodType =  try store.bloodType()
            
            //2. Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                              from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!
            
            //3. Unwrap the wrappers to get the underlying enum values.
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            let unwrappedBloodType = bloodType.bloodType
            
            return (age, unwrappedBiologicalSex, unwrappedBloodType)
            
        }
    }
    
    //https://stackoverflow.com/questions/36559581/healthkit-swift-getting-todays-steps
    class func getSteps(completion: @escaping (Double) -> Void){
        let store = HKHealthStore()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        store.execute(query)
        
    }
    
   
    
    
    func bloodstringRepresentation(t: HKBloodType) -> String {
        var r:String = ""
        switch t {
        case .notSet: r =  "Unknown"
        case .aPositive: r = "A+"
        case .aNegative: r =  "A-"
        case .bPositive: r = "B+"
        case .bNegative: r = "B-"
        case .abPositive: r = "AB+"
        case .abNegative: r = "AB-"
        case .oPositive: r = "O+"
        case .oNegative: r = "O-"
        @unknown default:
            print("Bruh")
        }
        return r
    }
    
}
