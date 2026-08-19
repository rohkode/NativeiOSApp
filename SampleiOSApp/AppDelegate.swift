//  AppDelegate.swift
//  SampleiOSApp
//  Created by Rohit Khandka on 29/05/23.

import UIKit
import CleverTapSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // App Launch

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Custom in-app templates MUST be registered before autoIntegrate() /
        // the CleverTap instance is created, or the SDK won't pick them up.
        CleverTap.registerCustom(inAppTemplates: BottomSheetTemplateProducer())

        // Sets up app-launch tracking, in-app notification display, and deep
        // link tracking automatically — no manual wiring needed for these.
        CleverTap.autoIntegrate()

        registerForPush()

        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.sharedInstance()?.enableDeviceNetworkInfoReporting(true)

        CleverTap.sharedInstance()?.initializeInbox(callback: ({ (success) in
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount()
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount()
            print("Inbox Message:\(String(describing: messageCount))/\(String(describing: unreadCount)) unread")
        }))

        // TEMPORARY — syncs the bottom_sheet template schema to the dashboard.
        // Only needs to run once per new/changed template, from a debug build
        // logged in as a test profile. Remove before any release build.
        CleverTap.sharedInstance()?.syncCustomTemplates()

        return true
    }

    // Push Notification Setup

    /// Configures notification action categories (for rich push carousel
    /// buttons), sets the UNUserNotificationCenter delegate, and requests
    /// permission from the user.
    func registerForPush() {
        // Multi-image carousel actions: Back / Next / View In App
        let actionBack = UNNotificationAction(identifier: "actionBack", title: "Back", options: [])
        let actionNext = UNNotificationAction(identifier: "actionNext", title: "Next", options: [])
        let actionView = UNNotificationAction(identifier: "actionView", title: "View In App", options: [])
        let multiImageCategory = UNNotificationCategory(
            identifier: "CTNotification",
            actions: [actionBack, actionNext, actionView],
            intentIdentifiers: [],
            options: []
        )

        // Single-image carousel: only needs the View In App action
        let singleImageCategory = UNNotificationCategory(
            identifier: "CTSingleCarousel",
            actions: [actionView],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([multiImageCategory, singleImageCategory])
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }

    // UNUserNotificationCenterDelegate

    /// Called when a push notification arrives while the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        NSLog("%@: will present notification: %@", self.description, notification.request.content.userInfo)

        if let aps = notification.request.content.userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                let title = alert["title"] ?? "nil"
                let body = alert["body"] ?? "nil"
                print("TITLE:", title)
                print("BODY:", body)
            } else if let body = aps["alert"] {
                print("BODY (string format):", body)
            }
        }

        // Required so CleverTap can attribute push delivery/viewed analytics correctly
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
        completionHandler([.badge, .sound, .alert])
    }

    /// Called when the user taps a notification (or one of its action buttons).
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        NSLog("%@: did receive notification response: %@", self.description, response.notification.request.content.userInfo)

        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                let title = alert["title"] ?? "nil"
                let body = alert["body"] ?? "nil"
                print("TAP TITLE:", title)
                print("TAP BODY:", body)
            } else if let body = aps["alert"] {
                print("TAP BODY (string format):", body)
            }
        }

        completionHandler()
    }

    // UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}
