//
//  BaseButtonBarPagerTabStripViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import Foundation
import XLPagerTabStrip

class BaseButtonBarPagerTabStripViewController: ButtonBarPagerTabStripViewController {
    private var observer: NSObjectProtocol?
    
    var api: CPLoveAPI {
        return CPLoveAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    lazy var crownBadge = CrownBadge.fromNib()! as! CrownBadge
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        containerView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        
        settings.style.buttonBarBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.buttonBarItemBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.selectedBarBackgroundColor = themeManager.themeData!.lightGray.hexColor
        settings.style.buttonBarItemTitleColor = themeManager.themeData!.textLabel.hexColor
        buttonBarView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        buttonBarView.reloadData()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.buttonBarItemBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.selectedBarBackgroundColor = themeManager.themeData!.lightGray.hexColor
        settings.style.buttonBarItemFont = UIFont(name: "Lato-Regular", size: 17.0)!
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = themeManager.themeData!.textLabel.hexColor
        settings.style.buttonBarItemsShouldFillAvailableWidth = true

        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = self.themeManager.themeData!.lightGray.hexColor
            newCell?.label.textColor = self.themeManager.themeData!.textLabel.hexColor
        }
        delegate = self
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
    }
    
    func addVIPNavLogo(leftAnchor: CGFloat = 0, title: String = "Become VIP") {
        let container = UIView()
        let crownBadge = CrownBadge.fromNib()! as! CrownBadge
        crownBadge.frame = container.bounds
        crownBadge.isUserInteractionEnabled = true
        crownBadge.button.addTarget(self, action: #selector(clickOnVIPNavLogo), for: .touchUpInside)
        container.addSubview(crownBadge)
        
        crownBadge.translatesAutoresizingMaskIntoConstraints = false
        crownBadge.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
        crownBadge.leftAnchor.constraint(equalTo: container.leftAnchor, constant: leftAnchor).isActive = true
        crownBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
        crownBadge.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 0).isActive = true
        crownBadge.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        crownBadge.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        crownBadge.config(text: title)
        
        navigationItem.titleView = container
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIViewController.topViewController == self else { return }

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "dark"])
            } else {
                NotificationCenter.default.post(name: ThemeManager.Notifications.ModeChanged, object: ["mode": "light"])
            }
        }
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
