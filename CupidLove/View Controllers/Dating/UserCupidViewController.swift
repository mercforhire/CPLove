//
//  UserCupidViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-16.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class UserCupidViewController: BaseViewController {
    private let itemInfo = IndicatorInfo(title: "CP Cupid")
    
    @IBOutlet weak var tableView: UITableView!
    
    private var cupids: [UserQuery]?
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    private var timer: Timer?
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }

    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        cupids == nil ? FullScreenSpinner().show() : nil
        
        let params = UserQueryParams()
        api.getExploredMatchmakerList(params: params) { result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let results = response.data?.records {
                    self.cupids = results
                    self.tableView.reloadData()
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notifications.RefreshBlurViews, object: nil)
    }
}

extension UserCupidViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension UserCupidViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cupids?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidStackCell", for: indexPath) as? CupidStackCell, let user = cupids?[indexPath.row] else {
            return CupidStackCell()
        }
        cell.config(user: user)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = cupids?[indexPath.row] else { return }
        
        openProfile(user: user)
    }
}
