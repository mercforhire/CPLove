//
//  BaseTabBarViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import UIKit

class BaseTabBarViewController: UITabBarController {
    var api: CPLoveAPI {
        return CPLoveAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openProfileFronNotification),
                                               name: Notifications.OpenProfile, object: nil)
        
        switch user.userType {
        case .normal:
            self.tabBar.tintColor = ThemeManager.shared.themeData!.pink.hexColor
        case .cupid:
            self.tabBar.tintColor = ThemeManager.shared.themeData!.blue.hexColor
        default:
            self.tabBar.tintColor = ThemeManager.shared.themeData!.pink.hexColor
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            handleRefreshForTabBar()
        }
    }
    
    func handleRefreshForTabBar() {
        DispatchQueue.main.async {
            guard let themeData = ThemeManager.shared.themeData else { return }
            
            self.tabBar.barStyle = ThemeManager.shared.barStyle
            
            switch self.user.userType {
            case .normal:
                self.tabBar.tintColor = themeData.pink.hexColor
            case .cupid:
                self.tabBar.tintColor = themeData.blue.hexColor
            default:
                self.tabBar.tintColor = themeData.pink.hexColor
            }
            
            self.tabBar.barTintColor = themeData.whiteBackground.hexColor
            self.tabBar.unselectedItemTintColor = themeData.tabBarTheme.unSelectedColor.hexColor
            self.tabBar.backgroundColor = themeData.whiteBackground.hexColor
        }
    }
    
    @objc func openProfileFronNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
                let userId = userInfo["userId"] as? String,
                let userType = userInfo["userType"] as? UserTypeMode else { return }
        
        if let topVC = UIViewController.topViewController {
            switch userType {
            case .normal:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "DatingProfileViewController") as! DatingProfileViewController
                vc.userId = userId
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .cupid:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.userId = userId
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .admin:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.userId = userId
                topVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
