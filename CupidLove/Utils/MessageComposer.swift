//
//  MessageComposer.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-24.
//

import Foundation
import MessageUI

class MessageComposer: NSObject {
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func canSendEmail() -> Bool {
        return MFMessageComposeViewController.canSendSubject() || UIApplication.shared.canOpenURL(URL(string: "mailto:abc@yahoo.com")!)
    }
    
    func configuredMessageComposeViewController(message: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.body = message
        messageComposeVC.messageComposeDelegate = self
        return messageComposeVC
    }
    
    func configuredEmailComposeViewController(subject: String, message: String) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.setSubject(subject)
        mailVC.setMessageBody(message, isHTML: false)
        mailVC.mailComposeDelegate = self
        return mailVC
    }
    
    func openSystemEmailContextMenu(myEmail: String, toRecipients: [String], ccRecipients: [String], bccRecipients: [String], subject: String, message: String) {
        guard UIApplication.shared.canOpenURL(URL(string: "mailto:abc@yahoo.com")!) else { return }
        
        var ccString: String = ""
        for cc in ccRecipients {
            if cc == ccRecipients.first {
                ccString = cc
            } else {
                ccString = "\(ccString), \(cc)"
            }
        }
        var bccString: String = ""
        for bcc in bccRecipients {
            if bcc == bccRecipients.first {
                bccString = bcc
            } else {
                bccString = "\(bccString), \(bcc)"
            }
        }
        let mailString: String = "mailto:\(myEmail)?cc=\(ccString)&bcc=\(bccString)?subject=\(subject)&body=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: mailString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension MessageComposer: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MessageComposer: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
