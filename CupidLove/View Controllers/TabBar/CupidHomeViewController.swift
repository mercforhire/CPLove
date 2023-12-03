//
//  CupidHomeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-04.
//

import UIKit

class CupidHomeViewController: BaseTabBarViewController {

    enum Tabs: Int {
        case homeCupid
        case chat
        case profileCupid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.viewControllers = [self]
        NotificationCenter.default.addObserver(self, selector: #selector(switchToChat), name: Notifications.SwitchToChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatBadgeCount), name: Notifications.UpdateChatBadge, object: nil)
    }
    
    @objc func switchToChat(_ notification: Notification) {
        if let modalVC = UIViewController.topViewController {
            modalVC.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                self.selectedIndex = Tabs.chat.rawValue
                if let navVC = self.viewControllers?[Tabs.chat.rawValue] as? UINavigationController, let topMostVC = navVC.viewControllers.last {
                    topMostVC.navigationController?.popToRootViewController(animated: true)
                }
                if let userInfo = notification.userInfo {
                    self.sendStartConversationNotification(userInfo: userInfo)
                }
            }
        }
    }
    
    private func sendStartConversationNotification(userInfo: [AnyHashable : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            NotificationCenter.default.post(name: Notifications.StartConversation, object: nil, userInfo: userInfo)
        })
    }
    
    @objc func updateChatBadgeCount(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let badgeCount = userInfo["badgeCount"] as? Int, badgeCount > 0 {
            tabBar.items?[Tabs.chat.rawValue].badgeValue = "\(badgeCount)"
        } else {
            tabBar.items?[Tabs.chat.rawValue].badgeValue = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
