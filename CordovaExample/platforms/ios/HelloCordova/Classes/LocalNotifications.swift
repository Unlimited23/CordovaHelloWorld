//
//  LocalNotifications.swift
//  TestNotifications
//
//  Created by Veronika Hristozova on 9/11/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import UIKit
import UserNotifications

public class LocalNotifications: NSObject {
    override init() {
        let state = UIApplication.shared.applicationState
        
        if state == .active {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                let options: UNAuthorizationOptions = [.alert, .sound]
                
                center.requestAuthorization(options: options) {
                    (granted, error) in
                    if !granted {
                        print("Something went wrong")
                    }
                }
                
                center.getNotificationSettings { (settings) in
                    if settings.authorizationStatus != .authorized {
                        // Notifications not allowed
                    }
                }
                
                
            } else {
                // iOS 9
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
                notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
                notification.alertAction = "be awesome!"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.scheduleLocalNotification(notification)
                
            }
        }
    }
    
    
    func removeAllNotifications() {
        
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
