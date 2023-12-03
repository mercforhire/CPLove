//
//  UserReportSuccessController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-15.
//

import UIKit

class UserReportSuccessController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func setup() {
        super.setup()
        
    }
    
    override func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        })
    }
}

extension UserReportSuccessController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popToRootViewController(animated: true)
    }
}
