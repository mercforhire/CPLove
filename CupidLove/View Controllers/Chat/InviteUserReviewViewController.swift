//
//  InviteUserReviewViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import UIKit

enum InviteType {
    case review
    case endorsement
}

class InviteUserReviewViewController: BaseViewController {
    @IBOutlet weak var searchField: ThemeBorderTextField!
    @IBOutlet weak var tableview: UITableView!
    private var inviteDialog: TwoChoicesDialog?
    
    private var conversations: [Conversation]?
    private var selectedConversation: Conversation?
    private var displaying: [Conversation] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    private var delayTimer = DelayedSearchTimer()
    
    override func setup() {
        super.setup()
        
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delayTimer.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if conversations == nil {
            fetchData()
        }
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        conversations == nil ? FullScreenSpinner().show() : nil
        
        api.getLatestMessages { [weak self] result in
            guard let self = self else { return }

            FullScreenSpinner().hide()

            switch result {
            case .success(let response):
                self.conversations = response.data?.records
                self.shouldSearch(text: self.searchField.text ?? "")
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        delayTimer.textDidGetEntered(text: textfield.text ?? "")
    }
    
    private func showInviteDialog() {
        let type: InviteType = user.userType == .normal ? .endorsement : .review

        var config: DialogConfig!
        switch type {
        case .review:
            config = DialogConfig(titleString: "Invite your friend to write a review!",
                                  primaryButtonLabel: "Send invitation",
                                  secondButtonLabel: "Cancel")
        case .endorsement:
            config = DialogConfig(titleString: "Invite your friend to write an endorsement!",
                                  primaryButtonLabel: "Send invitation",
                                  secondButtonLabel: "Cancel")
        }
        inviteDialog = TwoChoicesDialog()
        inviteDialog?.configure(config: config, showDimOverlay: true, overUIWindow: true)
        inviteDialog?.delegate = self
        inviteDialog?.show(inView: view, withDelay: 100)
    }
    
    override func buttonSelected(index: Int, dialog: TwoChoicesDialog) {
        guard let selectedUser = selectedConversation?.targetUserInfo,
                let conversationId = selectedConversation?.conversationId else { return }
        
        if index == 0 {
            FullScreenSpinner().show()
            
            userManager.sendReviewRequest(conversationId: conversationId, toUser: selectedUser) { [weak self] success in
                FullScreenSpinner().hide()

                if success {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func dismissedDialog(dialog: TwoChoicesDialog) {
        
    }
}

extension InviteUserReviewViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let searchText: String = text.trim()
        
        if searchText.count < 3 {
            displaying = conversations ?? []
        } else {
            displaying = (conversations ?? []).filter({ each in
                let nameFound = (each.targetUserInfo?.firstName?.contains(string: searchText, caseInsensitive: true) ?? false)
                let messageFound = (each.latestChatMessage?.content.contains(string: searchText, caseInsensitive: true) ?? false)
                
                return nameFound || messageFound
            })
        }
    }
}

extension InviteUserReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, displaying.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < displaying.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListCell", for: indexPath) as? MessageListCell else {
                return MessageListCell()
            }
            cell.config(data: displaying[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StartChattingCell", for: indexPath) as? StartChattingCell else {
                return StartChattingCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < displaying.count else { return }
        
        selectedConversation = displaying[indexPath.row]
        showInviteDialog()
    }
}
