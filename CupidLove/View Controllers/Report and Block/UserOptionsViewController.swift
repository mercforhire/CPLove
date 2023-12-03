//
//  UserOptionsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit

enum UserOptionsMenuRows: Int {
    case report
    case block
    case count
    
    func title() -> String {
        switch self {
        case .report:
            return "Report"
        case .block:
            return "Block"
        default:
            return ""
        }
    }
    
    func showArrow() -> Bool {
        switch self {
        case .report:
            return true
        default:
            return false
        }
    }
}

class UserOptionsViewController: BaseViewController {
    var targetUserId: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currentUser: UserInfo? {
        didSet {
            tableView.reloadData()
            if currentUser?.userType == .admin {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        tableView.contentInset = .init(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    private func fetchData() {
        currentUser == nil ? FullScreenSpinner().show() : nil
        
        api.fetchUserProfile(userId: targetUserId) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let user = response.data {
                    self.currentUser = user
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserReportOptionsViewController {
            vc.targetUserId = targetUserId
        }
    }
    
    private func showBlockConfirmation() {
        guard let currentUser = currentUser else {
            return
        }
        if currentUser.isBlocked ?? false {
            FullScreenSpinner().show()
            api.blockUser(userId: currentUser.identifier, block: false) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.data != nil {
                        self.fetchData()
                        self.userManager.fetchBlocked { _ in
                        }
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
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                
                FullScreenSpinner().show()
                self.api.blockUser(userId: currentUser.identifier, block: !(currentUser.isBlocked ?? false)) { [weak self] result in
                    guard let self = self else { return }
                    
                    FullScreenSpinner().hide()
                    
                    switch result {
                    case .success(let response):
                        if response.data != nil {
                            self.fetchData()
                            self.userManager.fetchBlocked { _ in
                            }
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
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func goToReportMenu() {
        performSegue(withIdentifier: "goToReport", sender: self)
    }
}

extension UserOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserOptionsMenuRows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionRowTableViewCell", for: indexPath) as? OptionRowTableViewCell else {
            return OptionRowTableViewCell()
        }
        
        let row = UserOptionsMenuRows(rawValue: indexPath.row)
        if row == .block {
            cell.label.text = (currentUser?.isBlocked ?? false) ? "Unblock" : row!.title()
        } else {
            cell.label.text = row!.title()
        }
        cell.rightArrow.isHidden = row!.showArrow() ? false : true
        cell.divider.isHidden = row != .report
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = UserOptionsMenuRows(rawValue: indexPath.row)
        switch row {
        case .report:
            goToReportMenu()
        case .block:
            showBlockConfirmation()
        default:
            break
        }
    }
}
