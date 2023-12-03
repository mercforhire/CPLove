//
//  ThreeChoicesDialog.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-05.
//

import Foundation
import UIKit

protocol ThreeChoicesDialogDelegate: class {
    func buttonSelected(index: Int, dialog: ThreeChoicesDialog)
    func dismissedDialog(dialog: ThreeChoicesDialog)
}

struct ThreeChoicesDialogConfig {
    var titleString : String = ""
    var primaryButtonLabel: String = ""
    var secondButtonLabel: String = ""
    var thirdButtonLabel: String = ""
    
    init(titleString : String,
         primaryButtonLabel: String,
         secondButtonLabel: String,
         thirdButtonLabel: String) {
        self.titleString = titleString
        self.primaryButtonLabel = primaryButtonLabel
        self.secondButtonLabel = secondButtonLabel
        self.thirdButtonLabel = thirdButtonLabel
    }
}

class ThreeChoicesDialog: UIView {
    // MARK: - Constants
    private let animationInterval: Double = 0.45
    private let edgeMargin: CGFloat = 10.6
    
    // MARK: - IBOutlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var tutorialContainerView: UIView!
    @IBOutlet private var dimBackground: UIView!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryActionButton: UIButton!
    @IBOutlet weak var secondaryActionButton: UIButton!
    @IBOutlet weak var thirdActionButton: UIButton!
    
    // MARK: - Variables
    weak var delegate: ThreeChoicesDialogDelegate?
    
    private var showDimOverlay: Bool = false
    // sometimes adding tutorial view breaks autolayout constraints. In this case, add tutorial view as a subview of UI window instead
    private var overUIWindow: Bool = false
    private var config: ThreeChoicesDialogConfig?
    
    private func setupUI() {
        Bundle.main.loadNibNamed("ThreeChoicesDialog", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.roundCorners()
        
        dimBackground.alpha = 0
        dimBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        tutorialContainerView.alpha = 0
        tutorialContainerView.roundCorners(style: .large)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        frame.size.height = UIScreen.main.bounds.size.height
        frame.size.width = UIScreen.main.bounds.size.width
    }
    
    // MARK: - Public
    func configure(config: ThreeChoicesDialogConfig,
                   showDimOverlay: Bool = false,
                   overUIWindow: Bool = false) {
        self.config = config
        self.showDimOverlay = showDimOverlay
        self.overUIWindow = overUIWindow
        titleLabel.text = config.titleString
        
        UIView.performWithoutAnimation {
            self.primaryActionButton.setTitle(config.primaryButtonLabel, for: .normal)
            self.secondaryActionButton.setTitle(config.secondButtonLabel, for: .normal)
            self.thirdActionButton.setTitle(config.thirdButtonLabel, for: .normal)
            self.layoutIfNeeded()
        }
    }
    
    func show(inView view: UIView, withDelay milliseconds: Int = 0) {
        if overUIWindow {
            guard let window = UIViewController.window else { return }
            
            window.addSubview(self)
        } else {
            view.addSubview(self)
        }
        
        func animateAndShow() {
            UIView.animate(withDuration: animationInterval) {
                self.showAllViews()
                self.layoutIfNeeded()
            }
        }
        
        if milliseconds == 0 {
            animateAndShow()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: animateAndShow)
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: animationInterval,
                       animations: {
                        self.hideAllViews()
                        self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            self.delegate?.dismissedDialog(dialog: self)
        }
    }
    
    // MARK: - Private
    private func hideAllViews() {
        tutorialContainerView.alpha = 0
        if showDimOverlay {
            dimBackground.alpha = 0
        }
    }
    
    private func showAllViews() {
        tutorialContainerView.alpha = 1
        if showDimOverlay {
            dimBackground.alpha = 1
        }
    }
    
    @IBAction func button1Press(_ sender: Any) {
        hide()
        delegate?.buttonSelected(index: 0, dialog: self)
    }
    
    @IBAction func button2Press(_ sender: Any) {
        hide()
        delegate?.buttonSelected(index: 1, dialog: self)
    }
    
    @IBAction func cancelPress(_ sender: Any) {
        hide()
        delegate?.buttonSelected(index: 1, dialog: self)
    }
}
