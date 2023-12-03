//
//  UIViewController+Extension.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-25.
//

import Foundation
import UIKit
import PhotosUI

extension UIViewController {
    var themeManager: ThemeManager {
        return ThemeManager.shared
    }
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return nil }
        return delegate
    }
    
    var user: MyUserInfo {
        return UserManager.shared.realUser!
    }
    
    func requestPhotoPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    func openProfile(user: MyUserInfo) {
        if let topVC = UIViewController.topViewController {
            switch user.userType {
            case .normal:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "DatingProfileViewController") as! DatingProfileViewController
                vc.forUser = user.toUserInfo()
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .cupid:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.forUser = user.toUserInfo()
                topVC.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func openProfile(user: UserInfo) {
        if let topVC = UIViewController.topViewController {
            switch user.userType {
            case .normal:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "DatingProfileViewController") as! DatingProfileViewController
                vc.forUser = user
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .cupid:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.forUser = user
                topVC.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func openProfile(user: UserQuery) {
        if let topVC = UIViewController.topViewController {
            switch user.userType {
            case .normal:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "DatingProfileViewController") as! DatingProfileViewController
                vc.userId = user.identifier
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .cupid:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.userId = user.identifier
                topVC.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func openProfile(user: InvitedByUserInfo) {
        if let topVC = UIViewController.topViewController {
            switch user.userType {
            case .normal:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "DatingProfileViewController") as! DatingProfileViewController
                vc.userId = user.identifier
                topVC.navigationController?.pushViewController(vc, animated: true)
            case .cupid:
                let vc = StoryboardManager.loadViewController(storyboard: "UserProfiles", viewControllerId: "CupidProfileViewController") as! CupidProfileViewController
                vc.userId = user.identifier
                topVC.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    @objc func clickOnVIPNavLogo() {
        //let vc = StoryboardManager.loadViewController(storyboard: "VIP", viewControllerId: "VIPHomeViewController")
        let vc = StoryboardManager.loadViewController(storyboard: "VIP", viewControllerId: "VIPPromotionCodeViewController")!
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIViewController {
    static var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
    
    static var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        
        return keyWindow?.topViewController()
    }
}
