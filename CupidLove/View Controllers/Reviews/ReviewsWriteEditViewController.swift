//
//  ReviewsWriteEditViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import Cosmos

class ReviewsWriteEditViewController: BaseViewController {
    var targetUserId: String!
    var review: ReviewRecord? {
        didSet {
            guard let review = review else { return }
            
            targetUserId = review.targetUserId
        }
    }
    
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var textField: ThemeTextView!
    @IBOutlet weak var saveButton: ThemeBarButton!
    
    override func setup() {
        super.setup()
        
        rating.rating = Double(review?.rating ?? 0)
        textField.text = review?.content
        
        if let review = review, let userInfoDto = review.userInfoDto?.first {
            title = "\(userInfoDto.firstName ?? "")'s review"
            textField.isEditable = review.userId == userManager.realUser?.identifier && review.targetUserId != userManager.realUser?.identifier
            rating.isUserInteractionEnabled = textField.isEditable
            if review.userId != userManager.realUser?.identifier {
                navigationItem.rightBarButtonItems = []
            }
        } else {
            title = "Write a review"
            rating.isUserInteractionEnabled = true
            textField.isEditable = true
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
        if let review = review, review.userId == userManager.realUser?.identifier {
            api.updateUserComment(commentID: review.identifier, targetUserId: targetUserId, content: textField.text, rating: Int(rating.rating), type: .review) { [weak self] result in
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
            api.saveUserComment(targetUserId: targetUserId, content: textField.text, rating: Int(rating.rating), type: .review) { [weak self] result in
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
