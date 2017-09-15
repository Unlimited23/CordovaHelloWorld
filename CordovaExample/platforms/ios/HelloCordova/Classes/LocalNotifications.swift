//
//  LocalNotifications.swift
//  TestNotifications
//
//  Created by Veronika Hristozova on 9/11/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import UIKit
import UserNotifications
import JavaScriptCore

public class LocalNotifications: NSObject {
    
    static public let shared = LocalNotifications()
    var jsContext: JSContext!
    
    func initializeJS() {
        jsContext = JSContext()
        
        // Specify the path to the jssource.js file.
        if let jsSourcePath = Bundle.main.path(forResource: "jssource", ofType: "js") {
            
            do {
                // Load its contents to a String variable.
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                // Add the Javascript code that currently exists in the jsSourceContents to the Javascript Runtime through the jsContext object.
                jsContext.evaluateScript(jsSourceContents)
                
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func helloWorld() -> String {
        if let variableHelloWorld = self.jsContext.objectForKeyedSubscript("helloWorld") {
            print(variableHelloWorld.toString())
        }
        return jsContext.objectForKeyedSubscript("helloWorld").call(withArguments: []).toString()
        
    }
    
    func setup() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
        initializeJS()
    }
    
    func sendNotification(title: String, body: String, hour: Int, minutes: Int) {
        
        //Clears previously sent notifications
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            //New Content
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .sound]
            
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
            }
            
//            center.getNotificationSettings { (settings) in
//                if settings.authorizationStatus != .authorized {
//                    // Notifications not allowed
//                }
//            }
            
            let content = UNMutableNotificationContent()
            content.title = helloWorld()
            content.body = body
            content.sound = UNNotificationSound.default()
            
            //To Present image in notification
            if let path = Bundle.main.path(forResource: "sunny", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attachment = try UNNotificationAttachment(identifier: "sunny", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("attachment not found.")
                }
            }
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minutes
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let identifier = "UYLLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            
            center.delegate = self
            center.add(request, withCompletionHandler: { error in
//                if _ = error {
//                    // Something went wrong
//                }
            })
        } else {
            //iOS >= 9
            UIApplication.shared.cancelAllLocalNotifications()
            
            
            //New content
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            
            
            
            var date = DateComponents()
            date.hour = hour
            date.minute = minutes
            
            notification.timeZone = TimeZone.current
            notification.fireDate = Calendar.current.date(from: date)
            notification.repeatInterval = NSCalendar.Unit.day
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    
    func removeAllNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            //iOS >= 9
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
}

extension LocalNotifications: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //        if let attachment = notification.request.content.attachments.first {
        //            if attachment.url.startAccessingSecurityScopedResource() {
        //                attachmentImage.image = UIImage(contentsOfFile: attachment.url.path)
        //                attachment.url.stopAccessingSecurityScopedResource()
        //            }
        //        }
        print(notification.request.content.attachments.count)
        
    }
}
