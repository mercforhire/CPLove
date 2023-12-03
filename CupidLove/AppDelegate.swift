//
//  AppDelegate.swift
//  CupidLove
//
//  Created by Leon Chen on 2021-10-01.
//

import UIKit
import IQKeyboardManagerSwift
import AWSS3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var lastNoti: UNNotificationResponse?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginFinished), name: Notifications.LoginFinished, object: nil)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        AppSettingsManager.shared.setDeviceToken(token: token)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func handleNoti(inApp: Bool, userInfo: [AnyHashable : Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
        if let type = userInfo["functionType"] as? String,
            let userId = userInfo["userId"] as? String,
            type == "CHAT" || type == "REVIEW" {
            if inApp {
                if (UIViewController.topViewController?.isKind(of: ChatHomeViewController.self) ?? false) ||
                    (UIViewController.topViewController?.isKind(of: ChatMessagesViewController.self) ?? false) {
                    NotificationCenter.default.post(name: Notifications.RefreshChat, object: nil, userInfo: ["userId": userId])
                }
                completionHandler?([.sound, .banner])
            } else {
                NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["userId": userId])
                completionHandler?([.sound, .banner])
            }
        }
    }
    
    @objc private func handleLoginFinished() {
        guard let lastNoti = lastNoti else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.handleNoti(inApp: false, userInfo: lastNoti.notification.request.content.userInfo)
            self.lastNoti = nil
        })
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show the notification alert (banner), and with sound
        print("userNotificationCenter willPresent:")
        print(notification.request.content.userInfo)
        handleNoti(inApp: true, userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // tell the app that we have finished processing the user’s action / response
        print("userNotificationCenter didReceive:")
        print(response.notification.request.content.userInfo)
        if UserManager.shared.isLoggedIn() && UserManager.shared.realUser == nil {
            lastNoti = response
        } else {
            handleNoti(inApp: false, userInfo: response.notification.request.content.userInfo)
        }
    }
}
