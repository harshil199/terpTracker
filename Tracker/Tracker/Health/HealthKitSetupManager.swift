//
//  HealthKitSetup.swift
//  Tracker
//
//  Created by Rushad Antia on 4/16/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import Foundation
import HealthKit


//HK setup found at https://www.raywenderlich.comn/459-healthkit-tutorial-with-swift-getting-started
class HealthKitSetupManager{
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard  let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount),
        let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
            else {
                
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       height,
                                                       bodyMass,
                                                       stepsCount, sleep]
        
   
        HKHealthStore().requestAuthorization(toShare: [],
                                             read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }
    
    
}
