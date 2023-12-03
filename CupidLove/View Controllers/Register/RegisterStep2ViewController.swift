//
//  RegisterStep2ViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-22.
//

import UIKit
import M13Checkbox

class RegisterStep2ViewController: BaseViewController {
    @IBOutlet weak var datingLabel1: ThemePinkLabel!
    @IBOutlet weak var datingLabel2: ThemeBlackTextLabel!
    
    @IBOutlet weak var cupidLabel1: ThemeBlueLabel!
    @IBOutlet weak var cupidLabel2: ThemeBlackTextLabel!
    
    var type: UserTypeMode = .normal
    
    @IBOutlet weak var emailField: ThemeBorderedRoundedPaddedTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailCodeField: ThemeBorderedRoundedPaddedTextField!
    @IBOutlet weak var emailCodeErrorLabel: UILabel!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var termsCheckbox: M13Checkbox!
    @IBOutlet weak var submitButton: UIButton!
    
    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
            } else {
                emailErrorLabel.text = ""
            }
        }
    }
    
    var emailCodeErrorString: String? {
        didSet {
            if let emailCodeErrorString = emailCodeErrorString, !emailCodeErrorString.isEmpty {
                emailCodeErrorLabel.text = emailCodeErrorString
            } else {
                emailCodeErrorLabel.text = ""
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        switch type {
        case .normal:
            datingLabel1.isHidden = false
            datingLabel2.isHidden = false
            cupidLabel1.isHidden = true
            cupidLabel2.isHidden = true
        case .cupid:
            datingLabel1.isHidden = true
            datingLabel2.isHidden = true
            cupidLabel1.isHidden = false
            cupidLabel2.isHidden = false
        case .admin:
            datingLabel1.isHidden = true
            datingLabel2.isHidden = true
            cupidLabel1.isHidden = false
            cupidLabel2.isHidden = false
        }
        
        emailField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        emailCodeField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        emailErrorLabel.text = ""
        emailCodeErrorLabel.text = ""
        
        termsCheckbox.stateChangeAnimation = .fill
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func submitPressed(_ sender: UIButton) {
        if termsCheckbox.checkState != .checked {
            showErrorDialog(error: "Must agree to the Terms of Use and Privacy Policy")
            return
        }
        
        if validate(step1Only: false),
           let email = emailField.text, !email.isEmpty,
           let code = emailCodeField.text, !code.isEmpty {
            FullScreenSpinner().show()
            
            userManager.register(email: email, code: code, userType: type) { [weak self] success in
                FullScreenSpinner().hide()
                if success {
                    self?.appSettings.setLastUsedEmail(email: email)
                    self?.userManager.proceedPassLogin()
                }
            }
        }
    }
    
    @IBAction func sendEmailCode(_ sender: UIButton) {
        guard validate(step1Only: true),
        let email = emailField.text, !email.isEmpty else { return }
        
        FullScreenSpinner().show()
        userManager.sendCode(email: email, login: false) { [weak self] success in
            FullScreenSpinner().hide()
            if success {
                self?.startCountdown()
            }
        }
    }
    
    @IBAction func termsPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://cplovedating.com/Terms.html")!)
    }
    
    @IBAction func privacyPressed(_ sender: UIButton) {
        openURLInBrowser(url: URL(string: "https://cplovedating.com/Terms.html")!)
    }
    
    private func validate(step1Only: Bool) -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        }
        
        if step1Only {
            emailErrorString = ""
            return true
        }
        
        if (emailCodeField.text ?? "").isEmpty {
            emailErrorString = ""
            emailCodeErrorString = "* Verification code is empty"
        } else {
            emailErrorString = ""
            emailCodeErrorString = ""
        }
        
        return true
    }
    
    private var seconds: Int = 60
    private func startCountdown() {
        seconds = 60
        sendCodeButton.isEnabled = false
        countDown()
    }
    
    private func countDown() {
        if seconds <= 0 {
            sendCodeButton.setTitle("Send code", for: .normal)
            sendCodeButton.isEnabled = true
        } else {
            sendCodeButton.setTitle("Resend(\(seconds))", for: .normal)
            seconds = seconds - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                self?.countDown()
            })
        }
    }
}


extension RegisterStep2ViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
