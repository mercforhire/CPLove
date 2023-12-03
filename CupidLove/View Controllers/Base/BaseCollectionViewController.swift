//
//  BaseCollectionViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController {
    
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
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        collectionView.reloadData()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }

}
