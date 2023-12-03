//
//  ChatMessagesViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit
import AVFoundation
import IQKeyboardManagerSwift

class ChatMessagesViewController: BaseViewController {
    private enum Status {
        case notExpired
        case expired
        case unlocked
    }
    
    let ChatExpireTextTemplate = "Chat expires in [X] days, become a VIP now!"
    let ChatExpiredText = "Chat has expired, Become VIP to talk forever"
    
    var selectedUserId: String!
    
    @IBOutlet weak var userNameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var heartIcon: ThemePinkImageView!
    @IBOutlet weak var vipView: UIView!
    @IBOutlet weak var expireLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var vipViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageBox: ThemeGrowingTextView!
    @IBOutlet weak var sendButton: ThemeRoundedPinkButton!
    private var unlockDialog: ThreeChoicesDialog?
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    private let bottomMarginDefault: CGFloat = 0
    
    
    private var data: ChatListData? {
        didSet {
            if let data = data {
                userNameLabel.text = data.targetUserInfo?.firstName
                heartIcon.isHidden = !(data.isLikeEachOther ?? false)
                
                if let expiredDays = data.expiredDays {
                    if expiredDays == 0 {
                        status = .expired
                    } else {
                        status = .notExpired
                    }
                } else {
                    status = .unlocked
                }
                
                tableView.reloadData()
                
                if !(data.chatPages?.records.isEmpty ?? true), !isLikeEachOther {
                    scrollToBottomOfChat()
                }
            }
        }
    }
    
    private var isLikeEachOther: Bool {
//        return (data?.isLikeEachOther ?? false) && !appSettings.getMatchedWithUsers().contains(selectedUserId)
        return (data?.isLikeEachOther ?? false)
    }
    
    private var status: Status = .notExpired {
        didSet {
            guard let data = data else { return }
            
            switch status {
            case .notExpired:
                expireLabel.text = ChatExpireTextTemplate.replacingOccurrences(of: "[X]", with: "\(data.expiredDays ?? 0)")
            case .expired:
                expireLabel.text = ChatExpiredText
            case .unlocked:
                vipViewHeight.constant = 0.0
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        vipViewHeight.constant = 0.0
        sendButton.isEnabled = false
    }

    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshChat), name: Notifications.RefreshChat, object: nil)
        userManager.talkingWithUserID = selectedUserId
        
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
        
        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: Notifications.RefreshChat, object: nil)
        userManager.talkingWithUserID = nil
        
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func fetchData(complete: ((Bool) -> Void)? = nil) {
        data == nil ? FullScreenSpinner().show() : nil
        
        let params = GetChatMessageParams(current: 1, size: 100, targetUserId: selectedUserId, userId: selectedUserId)
        api.getMessagesWithUser(params: params) { [weak self] result in
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let data = response.data {
                    self?.data = data
                    complete?(true)
                } else {
                    showErrorDialog(code: response.code)
                    complete?(false)
                }
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
    
    @objc func handleRefreshChat(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let userId = userInfo["userId"] as? String, selectedUserId == userId {
            fetchData { success in
                if success {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let message = messageBox.text,
                !message.isEmpty,
              let conversationId = data?.conversationId,
                let userQuery = data?.targetUserInfo else { return }
        
        FullScreenSpinner().show()
        
        userManager.sendChatMessage(conversationId: conversationId,
                                    msg: message,
                                    toUser: userQuery) { [weak self] success in
            FullScreenSpinner().hide()
            
            if success {
                self?.messageBox.text = ""
                sender.isEnabled = false
                self?.fetchData()
            }
        }
    }
    
    @IBAction func vipBannerPressed(_ sender: UIButton) {
        showUnlockDialog()
    }
    
    @IBAction func dismissVIPBanner(_ sender: UIButton) {
        vipViewHeight.constant = 0.0

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserOptionsViewController {
            vc.targetUserId = selectedUserId
        } else if let vc = segue.destination as? ReviewsWriteEditViewController {
            vc.targetUserId = selectedUserId
        }
    }
    
    private func scrollToBottomOfChat() {
        guard !(data?.chatPages?.records.isEmpty ?? true) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            guard let self = self else { return }
            
//            let offset = self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.contentInset.bottom
//
//            UIView.animate(withDuration: 0.33, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
//                self.tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
//            }, completion: nil)
            self.tableView.scrollToBottom()
        })
    }
    
    private func showUnlockDialog() {
        let config = ThreeChoicesDialogConfig(titleString: "Want to chat more?",
                                              primaryButtonLabel: "Become a VIP",
                                              secondButtonLabel: "Spent 50 coins",
                                              thirdButtonLabel: "Give up chat")
        unlockDialog = ThreeChoicesDialog()
        unlockDialog?.configure(config: config, showDimOverlay: true, overUIWindow: true)
        unlockDialog?.delegate = self
        unlockDialog?.show(inView: view, withDelay: 100)
    }
    
    @objc private func goToReview(_ sender: UIButton) {
        performSegue(withIdentifier: "goToWriteReview", sender: self)
    }
}

extension ChatMessagesViewController: ThreeChoicesDialogDelegate {
    func buttonSelected(index: Int, dialog: ThreeChoicesDialog) {
        if index == 0 {
            clickOnVIPNavLogo()
        } else if index == 1 {
            FullScreenSpinner().show()
            api.spendCoin(targetUserId: selectedUserId) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.succeed {
                        self.fetchData()
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
    
    func dismissedDialog(dialog: ThreeChoicesDialog) {
        
    }
    
    //MARK:  Keyboard show and hide methods
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.bottomMargin.constant = keyboardSize.size.height - (self.tabBarController?.tabBar.frame.size.height ?? 0)
                self.view.layoutIfNeeded()
            }
        }
        tableView.scrollToBottom()
    }
    
    @objc func keyboardWillHide(_: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomMargin.constant = self.bottomMarginDefault
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: .zero)
//        headerView.isUserInteractionEnabled = false
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let diff = tableView.contentSize.height - tableView.bounds.height
//        return diff > 0 ? 0 : -diff
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        
        if isLikeEachOther {
            return 1
        } else {
            return data.chatPages?.records.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = data else { return UITableViewCell() }
        
        if isLikeEachOther {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchCell, let talkingTo = data.targetUserInfo else {
                return MatchCell()
            }
            cell.config(myself: user, match: talkingTo)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let talkingTo = data.targetUserInfo, let message = data.chatPages?.records[indexPath.row] else { return UITableViewCell() }
            
            if message.fromUserId == user.identifier {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightChatCell", for: indexPath) as? ChatCell else {
                    return ChatCell()
                }
                
                cell.config(data: message, speaker: user.toUserQuery(), clickToOpenProfile: false)
                cell.button.removeTarget(self, action: #selector(goToReview), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftChatCell", for: indexPath) as? ChatCell else {
                    return ChatCell()
                }
                cell.button.addTarget(self, action: #selector(goToReview), for: .touchUpInside)
                cell.config(data: message, speaker: talkingTo, clickToOpenProfile: true)
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLikeEachOther {
            appSettings.addMatchedWithUsers(userId: selectedUserId)
            tableView.reloadData()
            scrollToBottomOfChat()
        }
    }
}

extension ChatMessagesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if status == .expired {
            showUnlockDialog()
            textView.resignFirstResponder()
            return
        }
        
        if isLikeEachOther {
            appSettings.addMatchedWithUsers(userId: selectedUserId)
            tableView.reloadData()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.trim().isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            sendMessage(sendButton)
            return false
        }
        return true
    }
}
