//  BottomSheetPresenter.swift
//  SampleiOSApp
//  Created by Rohit Khandka on 18/08/26.

import UIKit
import CleverTapSDK

class BottomSheetPresenter: NSObject, CTTemplatePresenter {

    private var sheetVC: UIViewController?
    private var activeContext: CTTemplateContext?

    func onPresent(context: CTTemplateContext) {
        activeContext = context

        // Verify exact getter names via Xcode autocomplete on CTTemplateContext —
        // likely stringNamed(_:) or getStringNamed(_:); confirm before relying on it.
        let title = context.string(name: "title")
        let message = context.string(name: "message")
        let ctaText = context.string(name: "ctaText")

        let sheet = UIViewController()
        sheet.view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0

        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(ctaText, for: .normal)
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, ctaButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        sheet.view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: sheet.view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: sheet.view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: sheet.view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])

        self.sheetVC = sheet

        if let sheetPC = sheet.sheetPresentationController {
            sheet.modalPresentationStyle = .pageSheet
            sheetPC.detents = [.medium()]
            sheetPC.prefersGrabberVisible = true
        } else {
            sheet.modalPresentationStyle = .overFullScreen
        }

        keyWindow()?.rootViewController?.present(sheet, animated: true)
        context.presented()
    }

    func onCloseClicked(context: CTTemplateContext) {
        sheetVC?.dismiss(animated: true)
        context.dismissed()
    }

    @objc private func ctaTapped() {
        guard let context = activeContext else { return }
            onCloseClicked(context: context)
        }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}
