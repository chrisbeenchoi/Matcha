//
//  AppDelegate.swift
//  Matcha
//
//  Created by Chris Choi on 8/10/23.
//

import Foundation
import UIKit
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //_ = Auth.auth() //unsure if this one is needed
        UNUserNotificationCenter.current().delegate = self
        
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // check if granted already or not. not needed EVERY TIME (though it does not hurt)
        requestNotificationPermission()
        return true
    }
    
    func requestNotificationPermission() {
        print("CALLING REQUEST NOTIF PERMISSION METHOD")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    print("notif permissions granted")
                    UIApplication.shared.delegate = self
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("Device Token:", tokenString)
        globalDeviceToken = tokenString
        print("device token stored globally: ", globalDeviceToken)
        UIApplication.shared.delegate = nil //so the rest of the app works
    }
    
    // what the notification will look like when app is in foreground
    // do this later. an alert would be good although I doubt anyone will be laying around scrolling the app atp
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // do whatever
        completionHandler([.badge, .sound, .banner])
    }
}
