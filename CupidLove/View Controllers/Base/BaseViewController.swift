//
//  BaseViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-09.
//

import UIKit
import AVKit

class BaseViewController: UIViewController {
    private var observer: NSObjectProtocol?
    
    var api: CPLoveAPI {
        return CPLoveAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    @IBOutlet weak var noResultsViewContainer: UIView!
    
    lazy var errorView = EmptyView.fromNib()! as! EmptyView
    
    var becomeVIPDialog: TwoChoicesDialog?
    
    var avatar: AvatarImage?
    
    static let tableRefreshDelay: TimeInterval = 0.35
    var mainTableView: UITableView?
    var tableRefreshTimer: Timer?
    
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if noResultsViewContainer != nil {
            noResultsViewContainer.fill(with: errorView)
            noResultsViewContainer.isHidden = true
        }
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard avatar != nil, let user = userManager.realUser else { return }
        
        avatar?.config(user: user, rounded: true)
    }
    
    func addAvatarButton() {
        avatar = AvatarImage(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatar?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToMyProfile))
        avatar?.addGestureRecognizer(tap)
        let menuBarItem = UIBarButtonItem(customView: avatar!)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 36).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 36).isActive = true
        navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc func goToMyProfile(_ sender: UITapGestureRecognizer) {
        // override
    }
    
    func addVIPNavLogo(leftAnchor: CGFloat = 0, title: String = "Become VIP") {
        let container = UIView()
        let crownBadge = CrownBadge.fromNib()! as! CrownBadge
        crownBadge.frame = container.bounds
        crownBadge.isUserInteractionEnabled = true
        crownBadge.button.addTarget(self, action: #selector(clickOnVIPNavLogo), for: .touchUpInside)
        container.addSubview(crownBadge)
        
        crownBadge.translatesAutoresizingMaskIntoConstraints = false
        crownBadge.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
        crownBadge.leftAnchor.constraint(equalTo: container.leftAnchor, constant: leftAnchor).isActive = true
        crownBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
        crownBadge.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 0).isActive = true
        crownBadge.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        crownBadge.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        crownBadge.config(text: title)
        
        navigationItem.titleView = container
    }
    
    func openToChat(userId: String) {
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["userId": userId])
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func playVideo(urlString: String) {
        guard let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let videoURL = URL(string: url) else { return }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIViewController.topViewController == self else { return }

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "dark"])
            } else {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "light"])
            }
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func showBecomeVIPDialog(forceShow: Bool) {
        if !forceShow,
            let lastShownDate = appSettings.getLastShownVIPDialogTime(),
            lastShownDate > Date().getPastOrFutureDate(min: -MinutesBeforeShowVIPDialogAgain) {
            print("Last Shown Date: \(lastShownDate), don't show VIP dialog for now.")
            return
        }
        
        let config = DialogConfig(titleString: "Better search results",
                                  primaryButtonLabel: "Become VIP Now",
                                  secondButtonLabel: "Maybe Later")
        becomeVIPDialog = TwoChoicesDialog()
        becomeVIPDialog?.configure(config: config, showDimOverlay: true, overUIWindow: true)
        becomeVIPDialog?.delegate = self
        becomeVIPDialog?.show(inView: view, withDelay: 100)
        
        appSettings.setLastShownVIPDialogTime(date: Date())
    }
    
    func refreshTableCellHeights(tableView: UITableView) {
        mainTableView = tableView
        
        if let timer = tableRefreshTimer {
            timer.invalidate()
            tableRefreshTimer = nil
        }
        tableRefreshTimer = Timer.scheduledTimer(timeInterval: BaseViewController.tableRefreshDelay,
                                                 target: self,
                                                 selector: #selector(tableRefreshTimerFired),
                                                 userInfo: nil,
                                                 repeats: false)
    }
    
    @objc func tableRefreshTimerFired() {
        tableRefreshTimer = nil
        
        mainTableView?.beginUpdates()
        mainTableView?.endUpdates()
    }
}

extension BaseViewController: DialogDelegate {
    @objc func buttonSelected(index: Int, dialog: TwoChoicesDialog) {
        if index == 0 {
            clickOnVIPNavLogo()
        }
    }
    
    @objc func dismissedDialog(dialog: TwoChoicesDialog) {
        
    }
}
