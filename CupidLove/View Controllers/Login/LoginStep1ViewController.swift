//
//  LoginStep1ViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-15.
//

import UIKit

class LoginStep1ViewController: BaseViewController {

    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForPushNotifications { [weak self] in
            guard let self = self else { return }
            
            if self.userManager.isLoggedIn() {
                print("is loggined in")
                self.loginUser()
            } else {
                print("is not loggined in")
            }
        }
    }
    
    private func registerForPushNotifications(complete: @escaping (() -> Void)) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            DispatchQueue.main.async {
                complete()
            }
        }
    }
    
    private func loginUser() {
        FullScreenSpinner().show()
        userManager.fetchUser(initialize: true) { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            if success {
                self.userManager.proceedPassLogin()
            } else {
                self.userManager.clearSavedInformation()
            }
        }
    }
    
    private var secretPressCount = 0
    @IBAction private func secretPressed(_ sender: UIButton) {
        secretPressCount+=1
        
        if secretPressCount > 10 {
            performSegue(withIdentifier: "goToMigration", sender: self)
            secretPressCount = 0
        }
    }
}
