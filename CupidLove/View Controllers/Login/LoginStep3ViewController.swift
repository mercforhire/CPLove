//
//  LoginStep3ViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-15.
//

import UIKit

class LoginStep3ViewController: BaseViewController {
    var type: UserTypeMode = .normal
    
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailUnderline: TextfieldUnderline!
    @IBOutlet weak var codeField: ThemeTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var codeUnderline: TextfieldUnderline!
    @IBOutlet weak var sendCodeButton: ThemeRoundedPinkButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString, !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
                emailUnderline.changeToErrorState()
            } else {
                emailErrorLabel.text = ""
                emailUnderline.changeToNormalState()
            }
        }
    }
    
    var codeErrorString: String? {
        didSet {
            if let codeErrorString = codeErrorString, !codeErrorString.isEmpty {
                codeErrorLabel.text = codeErrorString
                codeUnderline.changeToErrorState()
            } else {
                codeErrorLabel.text = ""
                codeUnderline.changeToNormalState()
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        emailErrorLabel.text = ""
        codeErrorLabel.text = ""
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailField.text = appSettings.getLastUsedEmail()
    }
    
    private func validate(step1Only: Bool) -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        } else {
            emailErrorString = ""
        }
        
        if step1Only {
            return true
        }
        
        if (codeField.text ?? "").isEmpty {
            codeErrorString = "* Validation code is empty"
            return false
        } else {
            codeErrorString = ""
        }
        
        return true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if validate(step1Only: false),
           let email = emailField.text, !email.isEmpty,
           let code = codeField.text, !code.isEmpty {
            
            FullScreenSpinner().show()
            
            userManager.login(email: email, code: code) { [weak self] success in
                FullScreenSpinner().hide()
                if success {
                    self?.appSettings.setLastUsedEmail(email: email)
                    self?.userManager.proceedPassLogin()
                }
            }
        }
    }
    
    @IBAction func sendCodePressed(_ sender: UIButton) {
        guard validate(step1Only: true),
        let email = emailField.text, !email.isEmpty else { return }
        
        FullScreenSpinner().show()
        userManager.sendCode(email: email, login: true) { [weak self] success in
            FullScreenSpinner().hide()
            if success {
                self?.startCountdown()
            }
        }
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
    
    private var tappedNumber: Int = 0 {
        didSet {
            if tappedNumber >= 10 {
                let ac = UIAlertController(title: nil, message: "Choose environment", preferredStyle: .actionSheet)
                let action1 = UIAlertAction(title: "Production\(AppSettingsManager.shared.getEnvironment() == .production ? "(Selected)" : "")", style: .default) { [weak self] action in
                    AppSettingsManager.shared.setEnvironment(environments: .production)
                    self?.clearFields()
                }
                ac.addAction(action1)
                
                let action2 = UIAlertAction(title: "Development\(AppSettingsManager.shared.getEnvironment() == .development ? "(Selected)" : "")", style: .default) { [weak self] action in
                    AppSettingsManager.shared.setEnvironment(environments: .development)
                    self?.clearFields()
                }
                ac.addAction(action2)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    self?.tappedNumber = 0
                }
                ac.addAction(cancelAction)
                present(ac, animated: true)
            }
        }
    }
    
    @IBAction func cheatButtonPress(_ sender: UIButton) {
        print("CheatButton Pressed")
        tappedNumber = tappedNumber + 1
    }
    
    private func clearFields() {
        UserManager.shared.clearSavedInformation()
        tappedNumber = 0
    }
}

extension LoginStep3ViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            // next action
            _ = codeField.becomeFirstResponder()
        } else if textField == codeField, !(textField.text?.isEmpty ?? true) {
            // return action
            loginPressed(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
