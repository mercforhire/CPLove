//
//  VIPSuccessViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-05.
//

import UIKit

class VIPSuccessViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func setup() {
        super.setup()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc private func donePressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

}

extension VIPSuccessViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessCell", for: indexPath) as? PromotionCodeAcceptedCell else {
            return PromotionCodeAcceptedCell()
        }
        cell.doneButton.addTarget(self, action: #selector(donePressed(_:)), for: .touchUpInside)
        return cell
    }
}
