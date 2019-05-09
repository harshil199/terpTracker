//
//  notificationPublisher.swift
//  Tracker
//
//  Created by Harshil Patel on 5/7/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
class notifcationPublisher : NSObject{
    
    func sendNotifcation(title: String, subtitle: String, body: String, badge: Int?,delayInterval: Int?){
        let notficationContent = UNMutableNotificationContent()
        notficationContent.title = title
        notficationContent.subtitle = subtitle
        notficationContent.body = body
        
        var delayTimeTrigger : UNTimeIntervalNotificationTrigger?
        if let delayInterval = delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        if let badge = badge{
            var currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentBadgeCount += badge
            notficationContent.badge = NSNumber(integerLiteral: currentBadgeCount)
        }
        
        notficationContent.sound = UNNotificationSound.default
        
        UNUserNotificationCenter.current().delegate = self
        
        
        let request = UNNotificationRequest(identifier: "HWTracker", content: notficationContent , trigger: delayTimeTrigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
}

extension notifcationPublisher: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification about to be presented")
        completionHandler([.badge, .sound, .alert])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifer = response.actionIdentifier
        
        switch identifer{
            
        case UNNotificationDismissActionIdentifier :
            print("The notifcation was dismissed")
            completionHandler()
        case UNNotificationDefaultActionIdentifier:
            print("The user opened the app from the notification")
            completionHandler()
        default:
            print("The default case was called")
            completionHandler()
        }
    }
}
