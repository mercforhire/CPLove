//
//  SettingsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class SettingsViewController: BaseTableViewController {
    enum SettingsTableRows: Int {
        case verify
        case privacy
        case separator1
        case delete
       
        func title() -> String {
            switch self {
            case .verify:
                return "Verify my account"
            case .privacy:
                return "Privacy"
            case .delete:
                return "Delete account"
            default:
                return ""
            }
        }
        
        static func getRows() -> [SettingsTableRows] {
            let rows: [SettingsTableRows] = [.verify, .privacy, .separator1, .delete]
            return rows
        }
    }
    
    var reason: String = ""
    
    override func setup() {
        super.setup()
        
        tableView.contentInset = .init(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Delete account", message: "Please select a reason for deleting your account", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Found/In a relationship", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Found/In a relationship"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Billing Issue", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Billing Issue"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Dissatisfied with service", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Dissatisfied with service"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Other", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.reason = "Other"
            self.showAreYouSure()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showAreYouSure() {
        let alert = UIAlertController(title: "Are you sure?", message: "Deleting your profile to create a new account may affect who you see on the platform, and we want you to have the best experience possible.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete account", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.showFinalConfirmationDialog()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showFinalConfirmationDialog() {
        let ac = UIAlertController(title: "Delete account?", message: "This action cannot be undone. Type \"delete\" to confirm.", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.keyboardType = .asciiCapable
            textfield.placeholder = "type delete"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [unowned ac] _ in
            if let answer = ac.textFields![0].text {
                if answer == "delete" {
                    FullScreenSpinner().show()
                    self.api.deleteUser(reason: self.reason) { [weak self] result in
                        
                        FullScreenSpinner().hide()
                        
                        switch result {
                        case .success(let result):
                            if result.data ?? false {
                                self?.userManager.logout()
                            } else {
                                showErrorDialog(code: result.code)
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
                    showErrorDialog(error: "\"delete\" was not typed, delete account action cancelled")
                }
            } else {
                showErrorDialog(error: "\"delete\" was not typed, delete account action cancelled")
            }
        }
        ac.addAction(confirmAction)
        
        present(ac, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsTableRows.getRows().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = SettingsTableRows.getRows()[indexPath.row]

        switch row {
        case .verify, .privacy, .delete:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountRowCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
            }
            cell.label.text = row.title()
            if row == .delete || row == .privacy {
                cell.divider.isHidden = true
            } else {
                cell.divider.isHidden = false
            }
            cell.selectionStyle = .none
            return cell
            
        case .separator1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                return SeparatorCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = SettingsTableRows.getRows()[indexPath.row]
        switch row {
        case .verify:
            performSegue(withIdentifier: "goToVerify", sender: self)
        case .privacy:
            performSegue(withIdentifier: "goToPrivacy", sender: self)
        case .delete:
            showDeleteConfirmation()
        default:
            break
        }
    }
}
