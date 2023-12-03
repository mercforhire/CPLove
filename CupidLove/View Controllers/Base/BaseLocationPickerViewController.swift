//
//  BaseLocationPickerViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-29.
//

import UIKit

class BaseLocationPickerViewController: LocationPickerViewController {
    var api: CPLoveAPI {
        return CPLoveAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.backgroundColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.barTintColor = themeManager.themeData!.navBarTheme.backgroundColor.hexColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.themeData!.navBarTheme.textColor.hexColor]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
