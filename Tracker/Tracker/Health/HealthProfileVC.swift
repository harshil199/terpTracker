//
//  HealthProfileVC.swift
//  Tracker
//
//  Created by Rushad Antia on 4/18/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import Foundation
import UIKit
import Charts
import HealthKit

class HealthProfileVC: UIViewController {
    
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var stepGoalTF: UITextField!
    @IBOutlet weak var sleepGoalTF: UITextField!
    
    @IBOutlet weak var hkBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the UI elements
        setupScreen()
        
        //auth the hk
        HealthKitSetupManager.authorizeHealthKit { (authorized, error) in
            
            if authorized {
                DispatchQueue.main.async {
                    self.hkBTN.setTitle("HealthKit Authorized", for: .normal)
                    self.hkBTN.isEnabled = false
                    self.hkBTN.layer.borderColor = UIColor.blue.cgColor
                    self.hkBTN.layer.borderWidth = 1
                    self.hkBTN.layer.cornerRadius = 3
                    
                    
                }
                
            }
            else {
                DispatchQueue.main.async {
                    self.hkBTN.setTitle("Enable in Health App", for: .normal)
                    self.hkBTN.layer.borderColor = UIColor.red.cgColor
                    self.hkBTN.layer.borderWidth = 2
                    self.hkBTN.layer.cornerRadius = 3
                }
            }
        }
        
    }
    
    func setupScreen(){
        //sets what the backbutton does
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "<- Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HealthProfileVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //add an observer for the tf change
        nameTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //check if Userdefaults has a key for the usrename
        if let un = UserDefaults.standard.string(forKey: "healthUserName"){
            nameTF.text = un
            goodTF()
        }
        
        if let stepsGoal = UserDefaults.standard.string(forKey: "healthStepGoal"){
            stepGoalTF.text = stepsGoal
        }
        
        if let sleepGoal = UserDefaults.standard.string(forKey: "healthSleepGoal"){
            sleepGoalTF.text = sleepGoal
        }
        
        //setup a tap recognizer to resign first responder
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardByTappingOutside))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    //resign first responder and change the color of it
    @objc func hideKeyboardByTappingOutside() {
        
        if nameTF.text != nil && nameTF.text != "" {
            goodTF()
        } else {
            errorTF()
        }
        
        //resign the keyboard
        resignFirstResponder()
        self.view.endEditing(true)
    }
    
    //#selector func for tf change
    @objc func textFieldDidChange(){
        goodTF()
    }
    
    //checks the fields
    @objc func back(sender: UIBarButtonItem) {
        if nameTF.text != nil && nameTF.text != "" {
            UserDefaults.standard.set(nameTF.text , forKey: "healthUserName")
            
            if stepGoalTF.text != nil && stepGoalTF.text != "" {
                UserDefaults.standard.set(stepGoalTF.text , forKey: "healthStepGoal")
            }
            
            if sleepGoalTF.text != nil && sleepGoalTF.text != "" {
                
                if let g = sleepGoalTF.text {
                    if Int(g)! > 0 && Int(g)! < 24 {
                        UserDefaults.standard.set(sleepGoalTF.text , forKey: "healthSleepGoal")
                    } else {
                        sleepGoalTF.layer.borderColor = UIColor.red.cgColor
                        sleepGoalTF.layer.borderWidth = 2
                        sleepGoalTF.layer.cornerRadius = 3
                        sleepGoalTF.text = ""
                        sleepGoalTF.placeholder = "Goal must be between 0 and 24 hrs."
                        return
                    }
                }
                
                
            }
            
            self.navigationController?.popViewController(animated: true)
        }else{
            errorTF()
        }
    }
    
    //makes a nice blue border around the textfield
    func goodTF(){
        nameTF.layer.borderColor = UIColor.blue.cgColor
        nameTF.layer.borderWidth = 1
        nameTF.layer.cornerRadius = 3
    }
    
    //makes a red border around the textfield
    func errorTF (){
        nameTF.layer.borderColor = UIColor.red.cgColor
        nameTF.layer.borderWidth = 2
        nameTF.layer.cornerRadius = 3
        nameTF.placeholder = "THIS FIELD IS REQUIRED"
    }
    
    
}
