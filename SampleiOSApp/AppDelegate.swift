//  AppDelegate.swift
//  SampleiOSApp
//  Created by Rohit Khandka on 29/05/23.
    
import UIKit
import CleverTapSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CleverTap.autoIntegrate()
        registerForPush()
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.sharedInstance()?.enableDeviceNetworkInfoReporting(true)
        
        
        CleverTap.sharedInstance()?.initializeInbox(callback: ({ (success) in
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount()
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount()
            print("Inbox Message:\(String(describing: messageCount))/\(String(describing: unreadCount)) unread")
        }))
        
        return true
    }
    
    func registerForPush() {
        // Multi-image carousel: Back, Next, View In App
        let actionBack = UNNotificationAction(identifier: "actionBack", title: "Back", options: [])
        let actionNext = UNNotificationAction(identifier: "actionNext", title: "Next", options: [])
        let actionView = UNNotificationAction(identifier: "actionView", title: "View In App", options: [])
        let multiImageCategory = UNNotificationCategory(identifier: "CTNotification", actions: [actionBack, actionNext, actionView], intentIdentifiers: [], options: [])
        
        // Single-image carousel: only View In App
            let singleImageCategory = UNNotificationCategory(
                identifier: "CTSingleCarousel",
                actions: [actionView],
                intentIdentifiers: [],
                options: []
            )
        
        UNUserNotificationCenter.current().setNotificationCategories([multiImageCategory, singleImageCategory])
        // Register for Push notifications
        UNUserNotificationCenter.current().delegate = self
        // request Permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: {granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            NSLog("%@: will present notification: %@", self.description, notification.request.content.userInfo)
            CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
            completionHandler([.badge, .sound, .alert])
        }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            
            NSLog("%@: did receive notification response: %@", self.description, response.notification.request.content.userInfo)
            completionHandler()
        }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
