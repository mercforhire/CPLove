//
//  BlackListViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class BlackListViewController: BaseTableViewController {
    var blacklist: [UserQuery]?
    
    private let CellIdentifier = "EmptyViewCell"
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        tableView.register(UINib(nibName: CellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: CellIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if blacklist == nil {
            fetchData()
        }
    }
    
    private func fetchData() {
        blacklist == nil ? FullScreenSpinner().show() : nil
        
        api.getMyBlockUserList { [weak self]  result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let results = response.data?.records {
                    self.blacklist = results
                    self.tableView.reloadData()
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
            
            FullScreenSpinner().hide()
        }
    }
    
    @objc private func unblockButtonPressed(sender: UIButton) {
        guard let selected = blacklist?[sender.tag] else { return }
        
        FullScreenSpinner().show()
        api.blockUser(userId: selected.identifier, block: false) { [weak self] result in
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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if blacklist?.count ?? 0 == 0 {
            return 1
        }
        return blacklist?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if blacklist?.count ?? 0 == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? EmptyViewCell else {
                return EmptyViewCell()
            }
            cell.config(style: .noSearchResults)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlackListCell", for: indexPath) as? BlackListCell,
              let user = blacklist?[indexPath.row] else {
            return BlackListCell()
        }
        cell.config(user: user)
        cell.unblock.tag = indexPath.row
        cell.unblock.addTarget(self, action: #selector(unblockButtonPressed(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
}
