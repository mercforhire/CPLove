//
//  AccountBasicInfoViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-28.
//

import UIKit

enum EditScreens: Int {
    case aboutMe
    case basicInfo
    
    func cellNames(mode: UserTypeMode) -> [String] {
        if mode == .normal {
            switch self {
            case .aboutMe:
                return ["SetupAboutYouCell"]
            case .basicInfo:
                return ["SetupSelfCell", "SetupCareerCell", "SetupGenderPerfForCell", "SetupAssetsCell"]
            }
        } else {
            switch self {
            case .aboutMe:
                return ["SetupAboutYouCell"]
            case .basicInfo:
                return ["SetupSelfCell", "SetupCareerCell"]
            }
        }
    }
}

class EditBasicInfoViewController: BaseViewController {    
    var screen: EditScreens = .aboutMe
    var mode: UserTypeMode = .normal
    
    @IBOutlet weak var tableView: UITableView!
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
    }
    
}

extension EditBasicInfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen.cellNames(mode: mode).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stepName = screen.cellNames(mode: mode)[indexPath.row]
        
        var tableCell: UITableViewCell!
        
        switch stepName {
        case "SetupAboutYouCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupAboutYouCell else {
                return SetupAboutYouCell()
            }
            cell.titleLabel.textColor = mode == .normal ? themeManager.themeData!.pink.hexColor : themeManager.themeData!.blue.hexColor
            tableCell = cell
        case "SetupSelfCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupSelfCell else {
                return SetupSelfCell()
            }
            tableCell = cell
        case "GetStartedGenderCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? GetStartedGenderCell else {
                return GetStartedGenderCell()
            }
            tableCell = cell
        case "SetupCareerCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupCareerCell else {
                return SetupCareerCell()
            }
            tableCell = cell
        case "SetupGenderPerfForCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupGenderPerfForCell else {
                return SetupGenderPerfForCell()
            }
            tableCell = cell
        case "SetupAssetsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: stepName, for: indexPath) as? SetupAssetsCell else {
                return SetupAssetsCell()
            }
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}
