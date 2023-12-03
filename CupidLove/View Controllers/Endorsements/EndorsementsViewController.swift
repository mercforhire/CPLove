//
//  EndorsementsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import CRRefresh

class EndorsementsViewController: BaseTableViewController {
    var forUser: UserInfo! {
        didSet {
            title = "\(user.firstName ?? "[USER]")'s endorsements"
        }
    }
    var endorsements: [ReviewRecord] = []
    var ableToWrite: Bool!
    
    enum EndorTableRows: Int {
        case writeEndorsement
        case endorsement
        case noEndor
        
        static func getRows(number: Int, ableToWrite: Bool) -> [EndorTableRows] {
            var rows: [EndorTableRows] = ableToWrite ? [.writeEndorsement] : []
            for _ in 0..<number {
                rows.append(.endorsement)
            }
            if number == 0 {
                rows.append(.noEndor)
            }
            return rows
        }
    }
    
    
    private var selected: ReviewRecord?
    
    override func setup() {
        super.setup()
        
        if forUser == nil {
            forUser = user.toUserInfo()
        }
        
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
        endorsements.isEmpty ? FullScreenSpinner().show() : nil
        
        api.getUserCommentList(userId: forUser.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let endorsements = response.data?.records {
                    self.endorsements = endorsements
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
    
    @objc private func writePressed(sender: UIButton) {
        selected = nil
        performSegue(withIdentifier: "goToWrite", sender: self)
    }
    
    @objc private func editPressed(sender: UIButton) {
        let endorsement = endorsements[sender.tag]
        selected = endorsement
        performSegue(withIdentifier: "goToWrite", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EndorsementsWriteEditViewController {
            vc.endor = selected
            vc.targetUserId = forUser.identifier
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EndorTableRows.getRows(number: endorsements.count, ableToWrite: ableToWrite).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = EndorTableRows.getRows(number: endorsements.count, ableToWrite: ableToWrite)[indexPath.row]
        switch row {
        case .writeEndorsement:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteEndorsementCell", for: indexPath) as? ButtonTableCell else {
                return ButtonTableCell()
            }
            cell.button.addTarget(self, action: #selector(writePressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        case .noEndor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoEndorsementCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        case .endorsement:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleEndorsementTableViewCell", for: indexPath) as? SingleEndorsementTableViewCell else {
                return SingleEndorsementTableViewCell()
            }
            let endorsement = endorsements[indexPath.row - (ableToWrite ? 1 : 0)]
            cell.config(data: endorsement, expandAction: { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            })
            cell.editButton.isHidden = user.identifier != endorsement.userId
            cell.editButton.tag = indexPath.row - (ableToWrite ? 1 : 0)
            cell.editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = EndorTableRows.getRows(number: endorsements.count, ableToWrite: ableToWrite)[indexPath.row]
        switch row {
        case .endorsement:
            let data = endorsements[indexPath.row - (ableToWrite ? 1 : 0)]
            selected = data
            performSegue(withIdentifier: "goToWrite", sender: self)
        default:
            break
        }
    }
}
