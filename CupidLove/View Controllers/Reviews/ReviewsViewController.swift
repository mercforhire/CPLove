//
//  ReviewsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import CRRefresh

class ReviewsViewController: BaseTableViewController {
    var forUser: UserInfo!
    var reviews: [ReviewRecord] = []
    var ableToWrite: Bool!
    
    private enum ReviewTableRows: Int {
        case write
        case review
        case noData
        
        static func getRows(number: Int, ableToWrite: Bool) -> [ReviewTableRows] {
            var rows: [ReviewTableRows] = ableToWrite ? [.write] : []
            for _ in 0..<number {
                rows.append(.review)
            }
            if number == 0 {
                rows.append(.noData)
            }
            return rows
        }
    }
    
    private var selected: ReviewRecord?
    
    override func setup() {
        super.setup()
        
        if forUser == nil {
            forUser = userManager.realUser?.toUserInfo()
        }
        
        title = "\(forUser.firstName ?? "[USER]")'s reviews"
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        reviews.isEmpty ? FullScreenSpinner().show() : nil
        
        api.getUserCommentList(userId: forUser.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let reviews = response.data?.records {
                    self.reviews = reviews
                    self.tableView.reloadData()
                } else {
                    showErrorDialog(code: response.code)
                }
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
    
    @objc private func writePressed() {
        selected = nil
        performSegue(withIdentifier: "goToWrite", sender: self)
    }
    
    @objc private func editPressed(sender: UIButton) {
        let data = reviews[sender.tag]
        selected = data
        performSegue(withIdentifier: "goToWrite", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReviewsWriteEditViewController {
            vc.review = selected
            vc.targetUserId = forUser.identifier
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReviewTableRows.getRows(number: reviews.count, ableToWrite: ableToWrite).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = ReviewTableRows.getRows(number: reviews.count, ableToWrite: ableToWrite)[indexPath.row]
        switch row {
        case .write:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteReviewCell", for: indexPath) as? ButtonTableCell else {
                return ButtonTableCell()
            }
            cell.button.addTarget(self, action: #selector(writePressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        case .noData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoReviewCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        case .review:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleReviewTableViewCell", for: indexPath) as? SingleReviewTableViewCell else {
                return SingleReviewTableViewCell()
            }
            let review = reviews[indexPath.row - (ableToWrite ? 1 : 0)]
            cell.config(data: review, expandAction: { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            })
            cell.editButton.tag = indexPath.row - (ableToWrite ? 1 : 0)
            cell.editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = ReviewTableRows.getRows(number: reviews.count, ableToWrite: ableToWrite)[indexPath.row]
        switch row {
        case .review:
            let data = reviews[indexPath.row - (ableToWrite ? 1 : 0)]
            selected = data
            performSegue(withIdentifier: "goToWrite", sender: self)
        default:
            break
        }
    }
}
