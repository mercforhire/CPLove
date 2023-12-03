//
//  LikeVisitRootViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import XLPagerTabStrip

class LikeVisitRootViewController: BaseButtonBarPagerTabStripViewController {

    enum Tabs: Int {
        case liked
        case visited
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
        let child0: UIViewController! = StoryboardManager.loadViewController(storyboard: "LikedVisited", viewControllerId: "WhoLikedMeViewController")
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "LikedVisited", viewControllerId: "WhoVisitedMeViewController")
        return [child0, child1]
    }

}
