//
//  ThemeGrowingTextView.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-10.
//

import UIKit
import GrowingTextView

class ThemeGrowingTextView: GrowingTextView {

    private var observer: NSObjectProtocol?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = themeManager.themeData!.textFieldBackground.hexColor
        textColor = themeManager.themeData!.textLabel.hexColor
        addInset()
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

class ThemeRoundedGrowingTextView: GrowingTextView {

    private var observer: NSObjectProtocol?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupUI()
    }
    
    func setupUI() {
        roundCorners(style: .small)
        layer.borderWidth = 1.0
        layer.borderColor = themeManager.themeData!.textLabel.hexColor.cgColor
        backgroundColor = themeManager.themeData!.textFieldBackground.hexColor
        textColor = themeManager.themeData!.textLabel.hexColor
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }

    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
