//
//  AccountViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class AccountViewController: BaseTableViewController {

    enum AccountTableRows: Int {
        case becomeVipUser
        case becomeVipCupid
        case avatar
        case accountHeader
        case myLikes
        case myBlacklist
        case VIP
        case separator1
        case invite
        case promotionCode
        case settingHeader
        case accountSetting
//        case helpCenter
        case aboutUs
        case faq
        case feedback
        case separator2
        case logOut
        
        func title() -> String {
            switch self {
            case .accountHeader:
                return "Account"
            case .myLikes:
                return "My Likes"
            case .myBlacklist:
                return "My Blacklist"
            case .VIP:
                return "VIP"
            case .invite:
                return "Invite"
            case .promotionCode:
                return "Promotion Code"
            case .settingHeader:
                return "Setting"
            case .accountSetting:
                return "Account Settings"
//            case .helpCenter:
//                return "Help Center"
            case .aboutUs:
                return "About us"
            case .faq:
                return "FAQ"
            case .feedback:
                return "Feedback"
            case .logOut:
                return "Logout"
            default:
                return ""
            }
        }
        
        static func getRows(isVIP: Bool, isCupid: Bool) -> [AccountTableRows] {
            var rows: [AccountTableRows] = [.avatar, .accountHeader, .myLikes, .myBlacklist, .separator1, .invite, .promotionCode, .settingHeader, .accountSetting, .aboutUs, .faq, .feedback, .separator2, .logOut]
            if !isVIP {
                rows.insert(isCupid ? .becomeVipCupid : .becomeVipUser, at: 0)
            }
            return rows
        }
    }
    
    override func setup() {
        super.setup()

    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
    @objc func becomeVIPPressed(_ sender: UIButton) {
        clickOnVIPNavLogo()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountTableRows.getRows(isVIP: user.isVip, isCupid: user.userType == .cupid).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = AccountTableRows.getRows(isVIP: user.isVip, isCupid: user.userType == .cupid)[indexPath.row]

        switch row {
        case .becomeVipUser:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingBecomeVIPCell", for: indexPath) as? DatingBecomeVIPCell else {
                return DatingBecomeVIPCell()
            }
            cell.upgradeButton.addTarget(self, action: #selector(becomeVIPPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        case .becomeVipCupid:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidBecomeVIPCell", for: indexPath) as? CupidBecomeVIPCell else {
                return CupidBecomeVIPCell()
            }
            cell.upgradeButton.addTarget(self, action: #selector(becomeVIPPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        case .avatar:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountAvatarCell", for: indexPath) as? AvatarLabelCell else {
                return AvatarLabelCell()
            }
            cell.config(data: user)
            cell.selectionStyle = .none
            return cell
            
        case .accountHeader, .settingHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSectionHeaderCell", for: indexPath) as? LabelTableCell else {
                return LabelTableCell()
            }
            cell.headerLabel.text = row.title()
            cell.selectionStyle = .none
            return cell
            
        case .myLikes, .myBlacklist, .VIP, .invite, .promotionCode, .accountSetting, .aboutUs, .faq, .feedback, .logOut:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountRowCell", for: indexPath) as? LabelDividerTableCell else {
                return LabelDividerTableCell()
            }
            cell.label.text = row.title()
            if row == .VIP || row == .promotionCode || row == .feedback || row == .logOut {
                cell.divider.isHidden = true
            } else {
                cell.divider.isHidden = false
            }
            if row == .logOut {
                cell.label.textColor = themeManager.themeData?.pink.hexColor
            } else {
                cell.label.textColor = themeManager.themeData?.textLabel.hexColor
            }
            cell.selectionStyle = .none
            return cell
            
        case .separator1, .separator2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                return SeparatorCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = AccountTableRows.getRows(isVIP: user.isVip, isCupid: user.userType == .cupid)[indexPath.row]
        switch row {
        case .invite:
            performSegue(withIdentifier: "goToInvite", sender: self)
        case .aboutUs:
            openURLInBrowser(url: URL(string: "https://cplovedating.com/about.html")!)
        case .faq:
            openURLInBrowser(url: URL(string: "https://cplovedating.com/faq.html")!)
        case .VIP:
            becomeVIPPressed(UIButton())
        case .promotionCode:
            performSegue(withIdentifier: "goToPromotionCode", sender: self)
        case .myLikes:
            performSegue(withIdentifier: "goToMyLikes", sender: self)
        case .myBlacklist:
            performSegue(withIdentifier: "goToMyBlacklist", sender: self)
        case .accountSetting:
            performSegue(withIdentifier: "goToSettings", sender: self)
        case .feedback:
            performSegue(withIdentifier: "goToFeedback", sender: self)
        case .logOut:
            userManager.logout()
        default:
            break
        }
        
    }
}
