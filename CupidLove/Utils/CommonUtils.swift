//
//  CommonUtils.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-21.
//

import Foundation
import UIKit
import Fakery

let faker = Faker()
let SecondsBeforeCallingVisit = 5.0
let MinutesBeforeShowVIPDialogAgain = 60

typealias Action = () -> Void

class Notifications {
    static let RefreshBlurViews: Notification.Name = Notification.Name("RefreshBlurViews")
    static let SwitchToChat: Notification.Name = Notification.Name("SwitchToChat")
    static let RefreshChat: Notification.Name = Notification.Name("RefreshChat")
    static let StartConversation: Notification.Name = Notification.Name("StartConversation")
    static let UpdateChatBadge: Notification.Name = Notification.Name("UpdateChatBadge")
    static let OpenProfile: Notification.Name = Notification.Name("OpenProfile")
    static let LoginFinished: Notification.Name = Notification.Name("LoginFinished")
}

func showErrorDialog(code: Int) {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        var message = ""
        switch code {
        case 20001:
            message = "<Debug error> User ID cannot be empty"
        case 20002:
            message = "<Debug error> User does not exist"
        case 20003:
            message = "<Debug error> Picture URL cannot be empty"
        case 20004:
            message = "<Debug error> The user type cannot be empty"
        case 20005:
            message = "<Debug error> The user status must be 0 or 1"
        case 20006:
            message = "<Debug error> The user ip cannot be empty"
        case 20007:
            message = "The email has been registered"
        case 20008:
            message = "Incorrect verification code"
        case 20009:
            message = "<Debug error> Fail to save user information, please try again"
        case 20010:
            message = "User profile is not exist"
        case 20011:
            message = "Account blocked, contact administrator"
        case 20012:
            message = "<Debug error> Fail to update user info, please try again"
        case 20013:
            message = "<Debug error> The user is not complete the basic information"
        case 20014:
            message = "<Debug error> User can't block themselves"
        case 20015:
            message = "<Debug error> User can't like themselves"
        case 20016:
            message = "The invite code is invalid"
        case 20017:
            message = "<Debug error> The third party account has been bound by someone else, please try again"
        case 20020:
            message = "<Debug error> Share link cannot be empty"
        case 20021:
            message = "<Debug error> This account has been bound with other wechat accounts, please change the account and try again"
        case 20022:
            message = "The email cannot be empty"
        case 20023:
            message = "The email is invalid"
        case 20024:
            message = "The user is deleted, please use other email to register or login"
        case 20025:
            message = "Send email verify code time interval should more than 60 seconds"
        case 30001:
            message = "User profile is already exist"
        case 30002:
            message = "The first name cannot be empty"
        case 30003:
            message = "The horoscope option is invalid"
        case 30004:
            message = "The birth year option is invalid"
        case 30005:
            message = "The height option is invalid"
        case 30006:
            message = "The ethnicity option is invalid"
        case 30007:
            message = "The religion option is invalid"
        case 30008:
            message = "The school cannot be empty"
        case 30009:
            message = "The job title cannot be empty"
        case 30010:
            message = "The income option is invalid"
        case 30011:
            message = "The gender option is invalid"
        case 30012:
            message = "The looking for gender option is invalid"
        case 30013:
            message = "The looking for purpose option is invalid"
        case 30014:
            message = "The asset option is invalid"
        case 30015:
            message = "The sibling option is invalid"
        case 30016:
            message = "The child option is invalid"
        case 30017:
            message = "The user need to upload at least one photo"
        case 30018:
            message = "The user description cannot be empty"
        case 30019:
            message = "The user type is invalid"
        case 30020:
            message = "The user delete reason cannot be empty"
        case 30021:
            message = "The user desired minimum age should no less than 0"
        case 30022:
            message = "The user desired maximum age should no less than 0"
        case 30023:
            message = "The user desired minimum age should less than desired maximum age"
        case 30024:
            message = "The user desired minimum income should no less than 0"
        case 30025:
            message = "The user desired maximum income should no less than 0"
        case 30026:
            message = "The user desired minimum income should less than desired maximum income"
        case 40005:
            message = "User cannot comment themselves"
        case 40006:
            message = "User cannot comment repeatedly"
        case 90001:
            message = "<Debug error> Question id cannot be empty"
        case 90002:
            message = "<Debug error> Question is not exist"
        case 20027:
            message = "This user is deleted"
        case 50001:
            message = "Reached daily like limit, Become VIP to get unlimited likes"
        case 100001:
            message = "The target user id cannot be empty"
        case 100002:
            message = "The target user is not exist"
        case 100003:
            message = "The chat content cannot be empty"
        case 100004:
            message = "The user cannot chat with themselves"
        case 100005:
            message = "Fail to update the read status"
        case 100006:
            message = "User can't send message because they are blocked by target user"
        case 100007:
            message = "User can't send message to target user who is been blocked"
        case 100008:
            message = "User can't send message to a deleted user"
        case 100009:
            message = "Target user should bind at least one device"
        case 100010:
            message = "Device token cannot be empty"
        case 100011:
            message = "Chat is expired, become VIP to get unlimited chat"
        case 100012:
            message = "Chat function type cannot be empty"
        case 100013:
            message = "The chat content is not a function"
        case 60001:
            message = "VIP information is not exist"
        case 60002:
            message = "VIP code is already exist"
        case 60003:
            message = "VIP code is already redeemed"
        case 60004:
            message = "VIP code redeem failed"
        case 60005:
            message = "VIP code is invalid"
        case 60006:
            message = "One of the users is VIP, no need to spend coin"
        case 60007:
            message = "Coins are not enough"
        default:
            message = "Error: \(code)"
        }
        
        let ac = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func showErrorDialog(error: String) {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func showNetworkErrorDialog() {
    DispatchQueue.main.async {
        guard let topVC = UIViewController.topViewController else { return }
        
        let ac = UIAlertController(title: "", message: "Network error, please check Internet connection.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .default)
        ac.addAction(cancelAction)
        topVC.present(ac, animated: true)
    }
}

func fileSize(forURL url: Any) -> Double {
    var fileURL: URL?
    var fileSize: Double = 0.0
    if (url is URL) || (url is String) {
        if (url is URL) {
            fileURL = url as? URL
        }
        else {
            fileURL = URL(fileURLWithPath: url as! String)
        }
        var fileSizeValue = 0.0
        try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
    }
    return fileSize
}

func fileSize(forData data: Data) -> Double {
    let fileSize = Double(data.count / 1048576)
    return fileSize
}

func openURLInBrowser(url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
