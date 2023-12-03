//
//  EndorsementsWriteEditViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class EndorsementsWriteEditViewController: BaseViewController {
    var targetUserId: String!
    var endor: ReviewRecord? {
        didSet {
            guard let endor = endor else { return }
            
            targetUserId = endor.targetUserId
        }
    }
    
    @IBOutlet weak var textField: ThemeTextView!
    @IBOutlet weak var saveButton: ThemeBarButton!
    
    override func setup() {
        super.setup()
        
        textField.text = endor?.content
        
        if let endor = endor, let userInfoDto = endor.userInfoDto?.first {
            title = "\(userInfoDto.firstName ?? "")'s endorsement"
            textField.isEditable = endor.userId == userManager.realUser?.identifier && endor.targetUserId != userManager.realUser?.identifier
            if endor.userId != userManager.realUser?.identifier {
                navigationItem.rightBarButtonItems = []
            }
        } else {
            title = "Write an endorsement"
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        if textField.text.count < 11 {
            showErrorDialog(error: "Please write at least 1 sentence long")
            return
        }
        
        FullScreenSpinner().show()
        if let endor = endor, endor.userId == userManager.realUser?.identifier {
            api.updateUserComment(commentID: endor.identifier, targetUserId: targetUserId, content: textField.text, type: .endorsement) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.data ?? false {
                        self.navigationController?.popViewController(animated: true)
                    } else {
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
            }
        } else {
            api.saveUserComment(targetUserId: targetUserId, content: textField.text, type: .endorsement) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.data ?? false {
                        self.navigationController?.popViewController(animated: true)
                    } else {
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
            }
        }
    }

}
