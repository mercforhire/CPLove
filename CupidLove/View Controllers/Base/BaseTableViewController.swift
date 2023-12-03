//
//  BaseTableViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-29.
//

import UIKit

class BaseTableViewController: UITableViewController {
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
    
    static let tableRefreshDelay: TimeInterval = 0.3
    var mainTableView: UITableView?
    var tableRefreshTimer: Timer?
    
    var becomeVIPDialog: TwoChoicesDialog?
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        tableView.reloadData()
        
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

        setup()
    }
    
    func openToChat(with: UserInfo) {
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["userId": with.identifier])
    }
    
    func openToChat(with: UserQuery) {
        NotificationCenter.default.post(name: Notifications.SwitchToChat, object: nil, userInfo: ["userId": with.identifier])
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

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func refreshTableCellHeights(tableView: UITableView) {
        mainTableView = tableView
        
        if let timer = tableRefreshTimer {
            timer.invalidate()
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}

extension BaseTableViewController: DialogDelegate {
    @objc func buttonSelected(index: Int, dialog: TwoChoicesDialog) {
        if index == 0 {
            clickOnVIPNavLogo()
        }
    }
    
    @objc func dismissedDialog(dialog: TwoChoicesDialog) {
        
    }
}
