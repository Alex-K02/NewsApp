//
//  EmailService.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 17.09.24.
//

import Foundation
import MessageUI

class EmailServiceController: UIViewController, MFMailComposeViewControllerDelegate {
    private let subject: String = "Password resetting"
    private let body: String = "We heard that you lost your AboutIT password. Sorry about that!\n But don’t worry! You can use the following button to reset your password:"
    
    // Function to present the mail compose view controller
    func sendEmail(address: String) -> Bool {
        // Check if the device is configured to send email
        guard MFMailComposeViewController.canSendMail() else {
            print("Device is not configured to send email.")
            return false
        }

        // Create the mail compose view controller
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self // Set the delegate
        mailComposeViewController.setToRecipients(["fake68036@gmail.com"]) // Set recipient email(s)
        mailComposeViewController.setSubject(subject) // Set subject of the email

        // Check for iOS version and set message body (HTML or plain text)
        if #available(iOS 13.0, *) {
            mailComposeViewController.setMessageBody(body, isHTML: true)
        } else {
            mailComposeViewController.setMessageBody(body, isHTML: false)
        }

        // Present the mail compose view controller
        self.present(mailComposeViewController, animated: true, completion: nil)
        return true
    }

    // This method handles the result of the email action
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)

        // Handle the result
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sending failed: \(error?.localizedDescription ?? "Unknown error")")
        @unknown default:
            fatalError()
        }
    }
}

