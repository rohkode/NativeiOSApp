//  ViewController.swift
//  SampleiOSApp
//  Created by Rohit Khandka on 29/05/23.

import UIKit
import CleverTapSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var etIdentity: UITextField!
    
    @IBOutlet weak var etFName: UITextField!
    
    @IBOutlet weak var etEmail: UITextField!
    
    @IBOutlet weak var etPhone: UITextField!
    
    //btnUpdate
    @IBOutlet weak var UpdIdentity: UITextField!
    
    @IBOutlet weak var UpdFName: UITextField!
    
    @IBOutlet weak var UpdEmail: UITextField!
    
    @IBOutlet weak var UpdPhone: UITextField!

    
    //Enable Support for Universal (Deep) Link Tracking
//    func application(application: UIApplication, openURL url: NSURL,
//                     sourceApplication: String?, annotation: AnyObject) -> Bool {
//        CleverTap.sharedInstance()?.handleOpenURL(url, sourceApplication: sourceApplication)
//        return true
//    }

    // Swift 3
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//       CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: nil)
//       return true
//    }

    func open(_ url: URL, options: [String : Any] = [:],
                       completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: nil)
        completion?(false)
    }
    

    
    @IBAction func btnLogin(_ sender: Any) {
        
        let identity:String? = etIdentity.text
        let name:String? = etFName.text
        let email:String? = etEmail.text
        let phone:String? = etPhone.text
        
        print(identity!)
        print(name!)
        print(email!)
        print(phone!)
        
        let profile: Dictionary<String, AnyObject> = [
            //Update pre-defined profile properties
            "Identity": identity as AnyObject,
            "Name": name as AnyObject,
            "Email": email as AnyObject,
            "Phone": phone as AnyObject,
            //Update custom profile properties
            "Plan type": "Platinum" as AnyObject,
            "Favorite Food": "Hamburger" as AnyObject
        ]
        let defaults = UserDefaults.init(suiteName: "group.ct12.rnsample")
                defaults?.setValue(email, forKey: "email")
                defaults?.set(identity, forKey: "identity")
        
        CleverTap.sharedInstance()?.onUserLogin(profile)
        
    }
    
    @IBAction func btnUpdate(_ sender: Any) {

        let identity:String? = etIdentity.text
        let name:String? = etFName.text
        let email:String? = etEmail.text
        let phone:String? = etPhone.text
        let dob = NSDateComponents()
        dob.day = 23
        dob.month = 6
        dob.year = 1985

        let d = NSCalendar.current.date(from: dob as DateComponents)
        let profile: Dictionary = [
            "Name": name as AnyObject,                 // String
            "Identity": identity as AnyObject,                   // String or number
            "Email": email as AnyObject,              // Email address of the user
            "Phone": phone as AnyObject,                // Phone (with the country code, starting with +)
            "Gender": "M" as AnyObject,                          // Can be either M or F
            "Age": 28 as AnyObject,                              // Not required if DOB is set
            "DOB": d! as AnyObject,
            "Photo":"https://static.independent.co.uk/2023/12/05/09/1f9374ef9c8f706faa9b94dbef8cfe5bY29udGVudHNlYXJjaGFwaSwxNzAxNzkzMDgz-2.74414679.jpg" as AnyObject,   // URL to the Image

            // optional fields. controls whether the user will be sent email, push etc.
            "MSG-email": true as AnyObject,                     // Disable email notifications
            "MSG-push": false as AnyObject,                       // Enable push notifications
            "MSG-sms": true as AnyObject,                       // Disable SMS notifications
            "MSG-dndPhone": false as AnyObject,                   // Opt out phone number from SMS notifications
            "MSG-dndEmail": false as AnyObject,                   // Opt out email from email notifications
        ]

        CleverTap.sharedInstance()?.profilePush(profile)
    }
    
    @IBAction func btnEvent(_ sender: Any) {
        // event without properties
        CleverTap.sharedInstance()?.recordEvent("Category Viewed")
    }
    
    @IBAction func btnProperty(_ sender: Any) {
        
        // event with properties
        let props = [
            "Product name": "Casio Chronograph Watch",
            "Category": "Mens Accessories",
            "Price": 59.99,
            "Date": NSDate()
        ] as [String : Any]
        
        CleverTap.sharedInstance()?.recordEvent("Product viewed", withProps: props)
        
    }
    
    @IBAction func btnCharged (_ sender: Any) {
        
            //charged event
            let chargeDetails = [
                "Amount": 300,
                "Payment mode": "Credit Card",
                "Charged ID": 24052013
            ] as [String : Any]
            
            let item1 = [
                "Category": "books",
                "Book name": "The Millionaire next door",
                "Quantity": 1
            ] as [String : Any]
            
            let item2 = [
                "Category": "books",
                "Book name": "Achieving inner zen",
                "Quantity": 1
            ] as [String : Any]
            
            let item3 = [
                "Category": "books",
                "Book name": "Chuck it, let's do it",
                "Quantity": 5
            ] as [String : Any]
            
            CleverTap.sharedInstance()?.recordChargedEvent(withDetails: chargeDetails, andItems: [item1, item2, item3])
            
    }
    
    @IBAction func btnAppInbox(_ sender: Any) {

        // config the style of App Inbox Controller
            let style = CleverTapInboxStyleConfig.init()
            style.title = "App Inbox"
            style.backgroundColor = UIColor.white
            style.messageTags = ["Promotion", "Offers"]
            style.navigationBarTintColor = UIColor.white
            style.navigationTintColor = UIColor.white
            style.tabUnSelectedTextColor = UIColor.black
            style.tabSelectedTextColor = UIColor.black
            style.tabSelectedBgColor = UIColor.white
            style.firstTabTitle = "My First Tab"
            
//            if let inboxController = CleverTap.sharedInstance()?.newInboxViewController(with: style, andDelegate: self) {
//                let navigationController = UINavigationController.init(rootViewController: inboxController)
//                self.present(navigationController, animated: true, completion: nil)
//          }
        
        CleverTap.sharedInstance()?.recordEvent("App Inbox Event")
    }
    
    @IBAction func btnInApp(_ sender: Any) {
        
        CleverTap.sharedInstance()?.recordEvent("InApp Notification Event")

    }
    
    @IBAction func btnNativeDisplay(_ sender: Any) {
        
        CleverTap.sharedInstance()?.recordEvent("Native Display Event")
        
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })}
}
