//  NotificationService.swift
//  PushRich
//  Created by Rohit Khandka on 22/05/24.
import UserNotifications
import CTNotificationService
import CleverTapSDK

class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
     var bestAttemptContent: UNMutableNotificationContent?
     override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
         print("NSE called — Notification payload: \(request.content.userInfo)")
                 let userDefaults = UserDefaults(suiteName: "group.ct12.rnsample")
                 let isLoggedIn = userDefaults?.bool(forKey: "isLoggedIn") ?? false
                 let userId = userDefaults?.object(forKey: "identity")
                 let userEmail = userDefaults?.object(forKey: "email")
             
                 if isLoggedIn,
                            let id = userId,
                            let email = userEmail {

                             let profile: [String: Any] = [
                                 "Identity": id,
                                 "Email": email
                             ]
//                 if(userId != nil){f
//                     CleverTap.sharedInstance()?.onUserLogin(profile)
//                     let profile: Dictionary<String, Any> = [
//                         "Identity": userId as Any,         // String or number
//                         "Email":userEmail as Any
//                     ]

                     CleverTap.sharedInstance()?.onUserLogin(profile)
                 }
         CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: request.content.userInfo)
      super.didReceive(request, withContentHandler: contentHandler)
     }
}
