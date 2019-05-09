//
//  AppDelegate.swift
//  Tracker
//
//  Created by Harshil Patel on 4/12/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit
import UserNotifications


extension UINavigationController{
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private func requestNotifcationAuth(application: UIApplication){
        
        let center = UNUserNotificationCenter.current()
        let option : UNAuthorizationOptions = [.alert, .badge,.sound]
        center.requestAuthorization(options: option) { granted, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().tintColor = .red
        
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue), categories: nil))
        
        if UserDefaults.standard.value(forKey: "Event_data") != nil {
            Event_data = NSMutableArray(array: UserDefaults.standard.value(forKey: "Event_data") as! NSArray)
            
        }
        
        //        UIApplication.shared.cancelAllLocalNotifications()
        
        let Notifications = UIApplication.shared.scheduledLocalNotifications
        print(Notifications)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        PersistenceService.saveContext()
    }
    
    
    
    
    
}

