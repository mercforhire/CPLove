//
//  EditQuestionViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-29.
//

import UIKit
import IQKeyboardManagerSwift

class EditQuestionViewController: BaseViewController {
    var question: QuestionData!
    var answer: QuestionAnswer?
    
    @IBOutlet weak var questionLabel: ThemeBlackTextLabel!
    @IBOutlet weak var answerField: ThemeRoundedBorderedTextView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    private let bottomMarginDefault: CGFloat = 10
    
    override func setup() {
        super.setup()
        
        questionLabel.text = question.question
        answerField.text = answer?.answer
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        answer = QuestionAnswer(questionId: question.identifier, answer: answerField.text)
        
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.updateMyAnswer(answer: self.answer!) { result in
                switch result {
                case .success(let response):
                    if response.data ?? false {
                    } else {
                        isSuccess = true
                        showErrorDialog(code: response.code)
                    }
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.userManager.fetchUser(initialize: false) { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                if isSuccess {
                    self?.backPressed(sender)
                }
            }
        }
    }
    
    //MARK:  Keyboard show and hide methods
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.bottomMargin.constant = keyboardSize.size.height - (self.tabBarController?.tabBar.frame.size.height ?? 0)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomMargin.constant = self.bottomMarginDefault
            self.view.layoutIfNeeded()
        }
    }
}
