//
//  NotificationService.swift
//  RichPush
//
//  Created by Rohit Khandka on 22/05/24.
//

import UserNotifications

class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
     var bestAttemptContent: UNMutableNotificationContent?
     override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
      super.didReceive(request, withContentHandler: contentHandler)
     }
}
