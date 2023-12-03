//
//  MyLikesRootViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-02.
//

import UIKit
import XLPagerTabStrip

class MyLikesRootViewController: BaseButtonBarPagerTabStripViewController {

    enum Tabs: Int {
        case users
        case cupids
    }
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setup() {
        super.setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child0: UIViewController! = StoryboardManager.loadViewController(storyboard: "Account",
                                                                             viewControllerId: "MyLikedUsersViewController")
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Account",
                                                                             viewControllerId: "MyLikedCupidsViewController")
        return [child0, child1]
    }

}
