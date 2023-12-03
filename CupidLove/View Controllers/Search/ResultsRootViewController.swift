//
//  ResultsRootViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit
import XLPagerTabStrip

class ResultsRootViewController: BaseButtonBarPagerTabStripViewController {
    enum Tabs: Int {
        case dating
        case cupid
    }
    
    var datersSearchParams: UserQueryParams = UserQueryParams() {
        didSet {
            if let vc = viewControllers.first as? ResultsViewController {
                vc.searchParams = datersSearchParams
            }
        }
    }
    var cupidSearchParams: UserQueryParams = UserQueryParams() {
        didSet {
            if let vc = viewControllers.last as? ResultsViewController {
                vc.searchParams = cupidSearchParams
            }
        }
    }
    var currentTabUserType: UserTypeMode = .normal
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setup() {
        super.setup()
        
        if let params = appSettings.getDatersFilterParams() {
            datersSearchParams = params
        }
        
        if let params = appSettings.getCupidsFilterParams() {
            cupidSearchParams = params
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child0 = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "ResultsViewController") as! ResultsViewController
        child0.resultsType = .normal
        let child1 = StoryboardManager.loadViewController(storyboard: "Search", viewControllerId: "ResultsViewController") as! ResultsViewController
        child1.resultsType = .cupid
        return [child0, child1]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FilterViewController {
            vc.mode = currentTabUserType
            if currentTabUserType == .normal {
                vc.searchParams = datersSearchParams
            } else if currentTabUserType == .cupid {
                vc.searchParams = cupidSearchParams
            }
            vc.delegate = self
        }
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        
        guard progressPercentage == 1.0 else { return }
        
        currentTabUserType = UserTypeMode(rawValue: toIndex) ?? .normal
    }
}

extension ResultsRootViewController: FilterViewControllerDelegate {
    func searchParamGenerated(searchParams: UserQueryParams, userType: UserTypeMode) {
        if userType == .normal {
            datersSearchParams = searchParams
            appSettings.setDatersFilterParams(params: searchParams)
        } else if userType == .cupid {
            cupidSearchParams = searchParams
            appSettings.setCupidsFilterParams(params: searchParams)
        }
    }
}
