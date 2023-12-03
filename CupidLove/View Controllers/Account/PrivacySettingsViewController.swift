//
//  PrivacySettingsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import M13Checkbox

class PrivacySettingsViewController: BaseViewController {

    enum ViewProfileSelection: Int {
        case everyone
        case noone
    }
    
    enum PushMessagesSelection: Int {
        case all
        case noSystem
        case noMarketing
        case none
    }
    
    @IBOutlet var viewProfileCheckboxes: [M13Checkbox]!
    @IBOutlet var receivePushCheckboxes: [M13Checkbox]!
    
    private var selection1: ViewProfileSelection = .everyone {
        didSet {
            for box in viewProfileCheckboxes {
                if box.tag == selection1.rawValue {
                    box.checkState = .checked
                } else {
                    box.checkState = .unchecked
                }
            }
        }
    }
    private var selection2: PushMessagesSelection = .all {
        didSet {
            for box in receivePushCheckboxes {
                if box.tag == selection2.rawValue {
                    box.checkState = .checked
                } else {
                    box.checkState = .unchecked
                }
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        selection1 = { self.selection1 }()
        selection2 = { self.selection2 }()
    }
    
    override func setupTheme() {
        super.setupTheme()
        for box in viewProfileCheckboxes {
            box.tintColor = themeManager.themeData?.pink.hexColor
        }
        for box in receivePushCheckboxes {
            box.tintColor = themeManager.themeData?.pink.hexColor
        }
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for i in 0..<viewProfileCheckboxes.count {
            if viewProfileCheckboxes[i].tag == 0 {
                viewProfileCheckboxes[i].checkState = user.isProfileHide ? M13Checkbox.CheckState.unchecked : M13Checkbox.CheckState.checked
            } else if viewProfileCheckboxes[i].tag == 1 {
                viewProfileCheckboxes[i].checkState = user.isProfileHide ? M13Checkbox.CheckState.checked : M13Checkbox.CheckState.unchecked
            }
        }
        
        for i in 0..<receivePushCheckboxes.count {
            receivePushCheckboxes[i].checkState = receivePushCheckboxes[i].tag == user.notificationLevel ? M13Checkbox.CheckState.checked : M13Checkbox.CheckState.unchecked
        }
    }
    
    @IBAction func selection1CheckBoxChanged(_ sender: M13Checkbox) {
        var params = UpdateUserParams()
        params.isProfileHide = sender.tag == 1
        
        if sender.checkState == .checked {
            FullScreenSpinner().show()
            userManager.updateProfile(params: params) { [weak self] success in
                FullScreenSpinner().hide()
                
                if success {
                    self?.selection1 = ViewProfileSelection(rawValue: sender.tag)!
                }
            }
        } else {
            sender.checkState = .checked
        }
    }
    
    @IBAction func selection2CheckBoxChanged(_ sender: M13Checkbox) {
        var params = UpdateUserParams()
        params.notificationLevel = sender.tag
        
        if sender.checkState == .checked {
            FullScreenSpinner().show()
            userManager.updateProfile(params: params) { [weak self] success in
                FullScreenSpinner().hide()
                
                if success {
                    self?.selection2 = PushMessagesSelection(rawValue: sender.tag)!
                }
            }
        } else {
            sender.checkState = .checked
        }
    }
}
