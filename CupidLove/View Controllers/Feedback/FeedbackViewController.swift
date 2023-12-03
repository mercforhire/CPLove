//
//  FeedbackViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-02.
//

import UIKit

class FeedbackViewController: BaseTableViewController {

    private enum FeedbackTypeMode: Int {
        case positive
        case negative
    }
    
    private enum FeedbackSteps: Int {
        case step1
        case step2
        case step3
        
        func cellNames(feedbackType: FeedbackTypeMode) -> [String] {
            switch feedbackType {
            case .positive:
                switch self {
                case .step1:
                    return ["FeedbackStep1TableViewCell"]
                case .step2:
                    return ["FeedbackStep2TableViewCell"]
                case .step3:
                    return ["FeedbackStep4TableViewCell"]
                }
            case .negative:
                switch self {
                case .step1:
                    return ["FeedbackStep1TableViewCell"]
                case .step2:
                    return ["FeedbackStep3TableViewCell"]
                case .step3:
                    return ["FeedbackStep4TableViewCell"]
                }
            }
        }
    }
    
    private var step: FeedbackSteps = .step1 {
        didSet {
            tableView.reloadData()
        }
    }
    private var type: FeedbackTypeMode = .positive
    private var reason: String = ""
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.reloadData()
    }
    
    @objc func nextStepPressed() {
        step = FeedbackSteps(rawValue: min(FeedbackSteps.step3.rawValue, step.rawValue + 1)) ?? .step3
    }
    
    @objc func submitPressed() {
        if reason.isEmpty {
            showErrorDialog(error: "Please enter a reaspn")
            return
        }
        
        FullScreenSpinner().show()
        api.saveAppFeedback(feedback: reason, positive: type == .positive, tags: []) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let result):
                if !result.succeed {
                    showErrorDialog(code: result.code)
                } else {
                    self.step = FeedbackSteps(rawValue: min(FeedbackSteps.step3.rawValue, self.step.rawValue + 1)) ?? .step3
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
    
    @objc func positivePressed() {
        type = .positive
        nextStepPressed()
    }
    
    @objc func negativePressed() {
        type = .negative
        nextStepPressed()
    }
    
    @objc func donePressed() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return step.cellNames(feedbackType: type).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stepName = step.cellNames(feedbackType: type)[indexPath.row]
        
        var tableCell: UITableViewCell!
        
        switch stepName {
        case "FeedbackStep1TableViewCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? FeedbackStep1TableViewCell else {
                return FeedbackStep1TableViewCell() }
            cell.positiveButton.addTarget(self, action: #selector(positivePressed), for: .touchUpInside)
            cell.negativeButton.addTarget(self, action: #selector(negativePressed), for: .touchUpInside)
            tableCell = cell
        case "FeedbackStep2TableViewCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? FeedbackStep2TableViewCell else {
                return FeedbackStep2TableViewCell() }
            cell.textField.delegate = self
            cell.submitButton.addTarget(self, action: #selector(submitPressed), for: .touchUpInside)
            tableCell = cell
        case "FeedbackStep3TableViewCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? FeedbackStep3TableViewCell else {
                return FeedbackStep3TableViewCell() }
            cell.textField.delegate = self
            cell.submitButton.addTarget(self, action: #selector(submitPressed), for: .touchUpInside)
            tableCell = cell
        case "FeedbackStep4TableViewCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? FeedbackStep4TableViewCell else {
                return FeedbackStep4TableViewCell() }
            cell.doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reason = textView.text
    }
}
