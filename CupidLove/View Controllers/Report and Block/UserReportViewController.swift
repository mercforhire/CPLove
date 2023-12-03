//
//  UserReportViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit
import GrowingTextView

class UserReportViewController: BaseViewController {
    var targetUserId: String!
    var pickedReason: ReportType!
    
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var submitButton: UIButton!
    
    private let charCountLimit = 500
    
    override func setup() {
        super.setup()
        
        reasonLabel.text = pickedReason.title()
        textView.text = ""
        textView.addInset()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func submitPressed(_ sender: UIButton) {
        FullScreenSpinner().show()
        
        api.saveAppReport(reportType: pickedReason, description: textView.text, targetUserId: targetUserId) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if response.data != nil {
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                } else {
                    showErrorDialog(code: response.code)
                }
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                error.showErrorDialog()
            }
        }
    }
}

extension UserReportViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 150 characters
        return updatedText.count <= charCountLimit
    }
}
