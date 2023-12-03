//
//  CupidRootViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-18.
//

import UIKit
import XLPagerTabStrip

class CupidRootViewController: BaseButtonBarPagerTabStripViewController {

    enum Tabs: Int {
        case invite
        case dating
        case cupids
    }
    
    @IBOutlet weak var favoritesBadge: ThemeBlueBadgeSwift!
    @IBOutlet weak var crownContainer: UIView!
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setup() {
        super.setup()
        
        crownBadge.button.addTarget(self, action: #selector(clickOnVIPNavLogo), for: .touchUpInside)
        crownContainer.fill(with: crownBadge)
        crownBadge.config(text: userManager.currentMembership()?.name ?? "Become VIP")
        favoritesBadge.text = "\(user.likeAmount)"
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.post(name: Notifications.LoginFinished, object: nil, userInfo: nil)
    }
    
    var firstLaunch = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstLaunch {
            moveToViewController(at: 1)
            firstLaunch = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child0: UIViewController! = StoryboardManager.loadViewController(storyboard: "ExploreCupid", viewControllerId: "CupidInvitesViewController")
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "ExploreUser", viewControllerId: "UserDatingViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "ExploreUser", viewControllerId: "UserCupidViewController")
        return [child0, child1, child2]
    }

}
