//
//  ChatHomeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit
import CRRefresh
import AVFoundation

class ChatHomeViewController: BaseViewController {
    @IBOutlet weak var coinsButton: ThemeBarButton!
    @IBOutlet weak var searchField: ThemeBorderTextField!
    @IBOutlet weak var tableview: UITableView!
    
    private var conversations: [Conversation]?
    private var selectedUserId: String?
    private var displaying: [Conversation] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    private var delayTimer = DelayedSearchTimer()
    
    override func setup() {
        super.setup()
        
        tableview.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableview.cr.endHeaderRefresh()
            })
        }
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        addAvatarButton()
        refreshNavigationBar()
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
        
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleStartConversation), name: Notifications.StartConversation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshChat), name: Notifications.RefreshChat, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notifications.StartConversation, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notifications.RefreshChat, object: nil)
    }
    
    @objc func handleRefreshChat(_ notification: Notification) {
        fetchData { success in
            if success {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        conversations == nil ? FullScreenSpinner().show() : nil
        
        api.getLatestMessages { [weak self] result in
            guard let self = self else { return }

            FullScreenSpinner().hide()

            switch result {
            case .success(let response):
                self.conversations = response.data?.records.filter({ conversation in
                    guard let userId = conversation.targetUserInfo?.identifier else { return true }
                    
                    if self.userManager.blacklistedUserIds.contains(userId) {
                        return false
                    }
                    
                    return true
                })
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
        
        userManager.fetchUser(initialize: false) { [weak self] success in
            if success {
                self?.refreshNavigationBar()
            }
        }
    }
    
    @objc func handleStartConversation(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let userId = userInfo["userId"] as? String {
            openTalk(withUserId: userId)
        }
    }
    
    @objc override func goToMyProfile(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }

    @objc private func textFieldDidChange(_ textfield: UITextField) {
        delayTimer.textDidGetEntered(text: textfield.text ?? "")
    }
    
    private func openTalk(withUserId: String) {
        selectedUserId = withUserId
        performSegue(withIdentifier: "openConversation", sender: self)
    }
    
    private func refreshNavigationBar() {
        addVIPNavLogo(title: userManager.currentMembership()?.name ?? "Become VIP")
        coinsButton.title = "\(user.coins) coins"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatMessagesViewController, let selectedUserId = selectedUserId {
            vc.selectedUserId = selectedUserId
        }
    }
}

extension ChatHomeViewController: DelayedSearchTimerDelegate {
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

extension ChatHomeViewController: UITableViewDataSource, UITableViewDelegate {
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
        guard indexPath.row < displaying.count,
        let userId = displaying[indexPath.row].targetUserInfo?.identifier else { return }
        
        openTalk(withUserId: userId)
    }
}
