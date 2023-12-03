//
//  UserReportOptionsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit

class UserReportOptionsViewController: BaseViewController {
    var targetUserId: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var pickedReason: ReportType?
    
    override func setup() {
        super.setup()
        
        tableView.contentInset = .init(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func goToReportDetailsView(reason: String) {
        guard pickedReason != nil else { return }
        
        performSegue(withIdentifier: "goToReportDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserReportViewController {
            vc.targetUserId = targetUserId
            vc.pickedReason = pickedReason
        }
    }
}

extension UserReportOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportType.list().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionRowTableViewCell", for: indexPath) as? OptionRowTableViewCell else {
            return OptionRowTableViewCell()
        }
        
        let row = ReportType.list()[indexPath.row]
        cell.label.text = row.title()
        cell.divider.isHidden = row == .OTHERS
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = ReportType.list()[indexPath.row]
        
        pickedReason = row
        goToReportDetailsView(reason: row.title())
    }
}
