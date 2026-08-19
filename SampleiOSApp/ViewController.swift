//  ViewController.swift
//  SampleiOSApp

import UIKit
import CleverTapSDK
import CoreLocation

class ViewController: UIViewController, CleverTapInboxViewControllerDelegate, CleverTapDisplayUnitDelegate, CLLocationManagerDelegate {
    
    // Identity input fields

    private let etIdentity = ViewController.makeTextField(placeholder: "Identity")
    private let etFName = ViewController.makeTextField(placeholder: "Full Name")
    private let etEmail = ViewController.makeTextField(placeholder: "Email")
    private let etPhone = ViewController.makeTextField(placeholder: "Phone Number")
    
    private let locationManager = CLLocationManager()

    // App Inbox badge state

    private var inboxBadgeLabel: UILabel?

    // Native Display state

    private var contentStack: UIStackView?
    private let nativeDisplayCard = UIView()
    private var currentDisplayUnit: CleverTapDisplayUnit?
    private var hasRecordedViewedForCurrentUnit = false

    // Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "RK iOS Labs"

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        buildLayout()
        setupInboxBarButton()
        setupLocationTracking()

        // Register to receive Native Display content as campaigns become active
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Layout construction

    private func buildLayout() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 24
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        self.contentStack = content

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -32),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40)
        ])

        // Native Display renders here, natively, whenever CleverTap has content for it.
        // Hidden until displayUnitsUpdated actually delivers something.
        nativeDisplayCard.isHidden = true
        content.addArrangedSubview(nativeDisplayCard)

        content.addArrangedSubview(section(title: "Identity", views: [
            etIdentity, etFName, etEmail, etPhone
        ]))

        content.addArrangedSubview(section(title: "Profile", views: [
            button("On User Login", .systemBlue, #selector(btnLogin)),
            button("Push Profile Update", .systemBlue, #selector(btnUpdate))
        ]))

        content.addArrangedSubview(section(title: "Events", views: [
            button("Category Viewed (No Property)", .systemIndigo, #selector(btnEvent)),
            button("Product Viewed (with Properties)", .systemIndigo, #selector(btnProperty)),
            button("Charged Event", .systemIndigo, #selector(btnCharged)),
            button("Order Confirmation (Array Properties)", .systemIndigo, #selector(btnOrderConfirmation))
        ]))

        content.addArrangedSubview(section(title: "Engagement", views: [
            button("In-App Message", .systemTeal, #selector(btnInApp))
        ]))

        content.addArrangedSubview(section(title: "Session", views: [
            button("Logout", .systemRed, #selector(btnLogout))
        ]))
    }

    private func section(title: String, views: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false

        let header = UILabel()
        header.text = title.uppercased()
        header.font = .systemFont(ofSize: 13, weight: .semibold)
        header.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [header] + views)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func button(_ title: String, _ color: UIColor, _ action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
        return btn
    }

    private static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .tertiarySystemGroupedBackground
        tf.layer.cornerRadius = 10
        tf.setLeftPadding(12)
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }

    // Native Display

    /// Called by the SDK whenever active Native Display campaign content changes.
    /// This is data only — CleverTap doesn't render anything for you here.
    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        guard let unit = displayUnits.first else {
            nativeDisplayCard.isHidden = true
            currentDisplayUnit = nil
            return
        }

        currentDisplayUnit = unit
        hasRecordedViewedForCurrentUnit = false
        renderNativeDisplay(unit)
    }

    private func renderNativeDisplay(_ unit: CleverTapDisplayUnit) {
        nativeDisplayCard.subviews.forEach { $0.removeFromSuperview() }
        nativeDisplayCard.gestureRecognizers?.forEach { nativeDisplayCard.removeGestureRecognizer($0) }

        guard let contentItem = unit.contents?.first else {
            print("Native Display unit has no content items")
            nativeDisplayCard.isHidden = true
            return
        }

        print("Content item — title: \(contentItem.title ?? "nil"), message: \(contentItem.message ?? "nil"), iconUrl: \(contentItem.iconUrl ?? "nil"), mediaUrl: \(contentItem.mediaUrl ?? "nil")")

        nativeDisplayCard.backgroundColor = .secondarySystemGroupedBackground
        nativeDisplayCard.layer.cornerRadius = 16
        nativeDisplayCard.isHidden = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(nativeDisplayTapped))
        nativeDisplayCard.addGestureRecognizer(tap)
        nativeDisplayCard.isUserInteractionEnabled = true

        // Prefer the main media image if present; fall back to the small icon
        let imageURLString = contentItem.mediaUrl ?? contentItem.iconUrl

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemGroupedBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false

        nativeDisplayCard.addSubview(imageView)

        let hasText = !(contentItem.title ?? "").isEmpty || !(contentItem.message ?? "").isEmpty

        if hasText {
            // Image + text side by side, same layout as before
            imageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true

            let titleLabel = UILabel()
            titleLabel.text = contentItem.title
            titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            titleLabel.numberOfLines = 1

            let messageLabel = UILabel()
            messageLabel.text = contentItem.message
            messageLabel.font = .systemFont(ofSize: 13)
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 2

            let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
            textStack.axis = .vertical
            textStack.spacing = 2

            let rowStack = UIStackView(arrangedSubviews: [imageView, textStack])
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.alignment = .center
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            nativeDisplayCard.addSubview(rowStack)
            imageView.removeFromSuperview()
            rowStack.insertArrangedSubview(imageView, at: 0)

            NSLayoutConstraint.activate([
                rowStack.topAnchor.constraint(equalTo: nativeDisplayCard.topAnchor, constant: 16),
                rowStack.leadingAnchor.constraint(equalTo: nativeDisplayCard.leadingAnchor, constant: 16),
                rowStack.trailingAnchor.constraint(equalTo: nativeDisplayCard.trailingAnchor, constant: -16),
                rowStack.bottomAnchor.constraint(equalTo: nativeDisplayCard.bottomAnchor, constant: -16)
            ])
        } else {
            // Image-only card: let the image fill the card at a natural banner aspect ratio
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: nativeDisplayCard.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: nativeDisplayCard.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: nativeDisplayCard.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: nativeDisplayCard.bottomAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5)
            ])
        }

        if let urlString = imageURLString, let url = URL(string: urlString) {
            loadImage(from: url) { image in
                imageView.image = image
            }
        }

        if !hasRecordedViewedForCurrentUnit, let unitID = unit.unitID {
            CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: unitID)
            hasRecordedViewedForCurrentUnit = true
        }
    }

    @objc private func nativeDisplayTapped() {
        guard let unit = currentDisplayUnit, let unitID = unit.unitID else { return }

        CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unitID)

        if let actionUrlString = unit.contents?.first?.actionUrl,
           let url = URL(string: actionUrlString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    /// Minimal async image loader — avoids pulling in a third-party library
    /// just for this one use case.
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    // Location

    private func setupLocationTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        CleverTap.setLocation(newLocation.coordinate)
        print("Sent location to CleverTap:", newLocation.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error:", error.localizedDescription)
    }

    // Profile actions

    @objc func btnLogin() {
        let identity = etIdentity.text
        let name = etFName.text
        let email = etEmail.text
        let phone = etPhone.text

        let profile: [String: AnyObject] = [
            "Identity": identity as AnyObject,
            "Name": name as AnyObject,
            "Email": email as AnyObject,
            "Phone": phone as AnyObject,
            "Plan type": "Platinum" as AnyObject,
            "Favorite Food": "Hamburger" as AnyObject
        ]
        let defaults = UserDefaults(suiteName: "group.ct12.rnsample")
        defaults?.setValue(email, forKey: "email")
        defaults?.set(identity, forKey: "identity")

        CleverTap.sharedInstance()?.onUserLogin(profile)
    }

    @objc func btnUpdate() {
        let identity = etIdentity.text
        let name = etFName.text
        let email = etEmail.text
        let phone = etPhone.text

        let dob = NSDateComponents()
        dob.day = 23; dob.month = 6; dob.year = 1985
        let d = NSCalendar.current.date(from: dob as DateComponents)

        let profile: [String: AnyObject] = [
            "Name": name as AnyObject,
            "Identity": identity as AnyObject,
            "Email": email as AnyObject,
            "Phone": phone as AnyObject,
            "Gender": "M" as AnyObject,
            "Age": 28 as AnyObject,
            "DOB": d! as AnyObject,
            "MSG-email": true as AnyObject,
            "MSG-push": true as AnyObject,
            "MSG-sms": true as AnyObject,
            "MSG-dndPhone": false as AnyObject,
            "MSG-dndEmail": false as AnyObject,
        ]
        CleverTap.sharedInstance()?.profilePush(profile)
    }

    // Event tracking actions

    @objc func btnEvent() {
        CleverTap.sharedInstance()?.recordEvent("Category Viewed")
    }

    @objc func btnProperty() {
        let props: [String: Any] = [
            "Product name": "Dragon Slayer Skin Bundle",
                "Category": "Character Skins",
                "Price": 499.00,
                "Currency": "INR",
                "Item Type": "Weapon",              // Cosmetic / Weapon / Currency Pack / Battle Pass / Character
                "Game Mode": "Battle Royale",         // Which mode this item is relevant to
                "Rarity": "Legendary",                // Common / Rare / Epic / Legendary
                "Player Level": 42,                   // Viewer's current level at time of view
                "In-Game Currency Cost": 1200,        // Cost in soft/hard currency, separate from real-money price
                "Is Limited Time": true,              // Flags seasonal/event-exclusive items
                "Bundle Item Count": 5,                // Number of items included, if it's a bundle
                "Weapon Class": "Sniper Rifle",         // Sub-category for weapon-type items specifically
                "Battle Pass Tier": 34,        // Ties the item to a specific season or progression tier
                "Clan Exclusive": false,          // Whether this item requires clan/guild membership to unlock
                "Source Screen": "Store - Featured",    // Where in the app the item was viewed (Store, Reward Chest, Event Tab, etc.)
                "Discount Percentage": 20               // If the item is on sale, how much off — separate from raw Price
            ]
        CleverTap.sharedInstance()?.recordEvent("Product viewed", withProps: props)
    }

    @objc func btnCharged() {
        let chargeDetails: [String: Any] = [
            "Amount": 999,
            "Currency": "INR",
            "Payment mode": "Google Play Billing",   // or Apple IAP, UPI, Wallet, etc.
            "Charged ID": 24081901,
            "Transaction Type": "Real Money",         // Real Money vs In-Game Currency purchase
            "Player Level": 42,                       // Level at time of purchase — strong LTV/segmentation signal
            "Is First Purchase": false,               // Flags a player's very first monetization event
            "Discount Applied": true
        ]
        let item1: [String: Any] = [
            "Category": "Character Skins",
            "Item Name": "Dragon Slayer Skin",
            "Item Type": "Cosmetic",
            "Rarity": "Legendary",
            "Quantity": 1,
            "Game Mode": "Battle Royale"
        ]
        let item2: [String: Any] = [
            "Category": "Currency Pack",
            "Item Name": "5000 Gems",
            "Item Type": "Currency",
            "Rarity": "N/A",
            "Quantity": 1,
            "Game Mode": "N/A"
        ]
        CleverTap.sharedInstance()?.recordChargedEvent(withDetails: chargeDetails, andItems: [item1, item2])
    }

    @objc func btnOrderConfirmation() {
        let props: [String: Any] = [
            "Cart value": 1499.00,
            "Currency": "INR",
            "Cart items": ["Dragon Slayer Skin", "5000 Gems", "Battle Pass - Season 12"],
            "Order ID": "ORD-2026-081934",
            "Payment mode": "Google Play Billing",
            "Item Count": 3,
            "Player Level": 42,
            "Game Mode": "Battle Royale",
            "Is First Purchase": false
        ]
        CleverTap.sharedInstance()?.recordEvent("Order Confirmation", withProps: props)
        showToast(message: "Order Confirmation Sent", font: .systemFont(ofSize: 14))
    }

    // In-app trigger

    @objc func btnInApp() {
        CleverTap.sharedInstance()?.recordEvent("InApp Notification Event")
    }

    // App Inbox

    private func setupInboxBarButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "tray.full"), for: .normal)
        button.addTarget(self, action: #selector(btnAppInbox), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)

        let badge = UILabel(frame: CGRect(x: 16, y: -4, width: 16, height: 16))
        badge.backgroundColor = .systemRed
        badge.textColor = .white
        badge.font = .systemFont(ofSize: 10, weight: .bold)
        badge.textAlignment = .center
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true
        badge.isHidden = true
        button.addSubview(badge)
        self.inboxBadgeLabel = badge

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)

        CleverTap.sharedInstance()?.registerInboxUpdatedBlock { [weak self] in
            self?.refreshInboxBadge()
        }
        refreshInboxBadge()
    }

    private func refreshInboxBadge() {
        let unread = CleverTap.sharedInstance()?.getInboxMessageUnreadCount() ?? 0
        inboxBadgeLabel?.text = "\(unread)"
        inboxBadgeLabel?.isHidden = unread == 0
    }

    @objc func btnAppInbox() {
        CleverTap.sharedInstance()?.fetchInbox { success in
            print("Inbox fetch completed, success:", success)
        }

        let style = CleverTapInboxStyleConfig()
        style.title = "App Inbox"
        style.backgroundColor = .white
        style.navigationBarTintColor = .systemBlue
        style.navigationTintColor = .white
        style.tabUnSelectedTextColor = .darkGray
        style.tabSelectedTextColor = .systemBlue
        style.tabSelectedBgColor = .white

        if let inboxController = CleverTap.sharedInstance()?.newInboxViewController(with: style, andDelegate: self) {
            let navigationController = UINavigationController(rootViewController: inboxController)
            present(navigationController, animated: true, completion: nil)
        }
    }

    // CleverTapInboxViewControllerDelegate

    func messageDidSelect(_ message: CleverTapInboxMessage, at index: Int32, withButtonIndex buttonIndex: Int32) {
        guard let content = message.content?[Int(index)] as? CleverTapInboxMessageContent else { return }

        var ctaURLString: String?

        if buttonIndex < 0 {
            if content.actionHasUrl, let url = content.actionUrl, !url.isEmpty {
                ctaURLString = url
            }
        } else if content.actionHasLinks {
            let customExtras = content.customDataForLink(at: buttonIndex)
            if let extras = customExtras, !extras.isEmpty {
                print("Inbox button custom extras:", extras)
                return
            }
            if let link = content.urlForLink(at: buttonIndex), !link.isEmpty {
                ctaURLString = link
            }
        }

        guard let urlString = ctaURLString, let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func messageButtonTapped(withCustomExtras customExtras: [AnyHashable: Any]?) {
        print("App Inbox button tapped with custom extras:", customExtras ?? [:])
    }

    // Deep link handling

    func open(_ url: URL, options: [String: Any] = [:], completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: nil)
        completion?(false)
    }

    // Logout / reset

    @objc func btnLogout() {
        guard let accountId = CleverTap.sharedInstance()?.config.accountId else { return }

        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: libraryPath)
            for file in files where file.contains("clevertap-\(accountId)") {
                try fileManager.removeItem(atPath: "\(libraryPath)/\(file)")
            }
        } catch {
            print("Error deleting CleverTap files:", error)
        }

        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.lowercased().contains("wizrocket") || key.lowercased().contains("wzrk") {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()

        let shared = UserDefaults(suiteName: "group.ct12.rnsample")
        shared?.removePersistentDomain(forName: "group.ct12.rnsample")
        shared?.synchronize()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CleverTap.autoIntegrate()
            print("CleverTap reset complete")
        }
    }

    // Misc UI helpers

    func showToast(message: String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 90, y: view.frame.height - 120, width: 180, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastLabel.textColor = .white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.4, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0
        }, completion: { _ in toastLabel.removeFromSuperview() })
    }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = padding
        leftViewMode = .always
    }
}
