//  NotificationViewController.swift
//  CTContentExtension
//  Created by Rohit Khandka on 15/07/25.

import UIKit
import UserNotifications
import UserNotificationsUI
import CleverTapSDK
import CTNotificationContent

class NotificationViewController: CTNotificationViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
    
  
  // Optional: Implement to get user event data
  override func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
    print("userDidPerformAction \(action) with props \(String(describing: properties))")
  }
    
  
  // Optional: Implement to get notification response
  override func userDidReceive(_ response: UNNotificationResponse?) {
    print("Push Notification Payload \(String(describing: response?.notification.request.content.userInfo))")
      
    
    if let notificationPayload = response?.notification.request.content.userInfo {
      if response?.actionIdentifier == "actionNext" {
        CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: notificationPayload)
      }
    }
  }
}
