//
//  UITextfield+Extension.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import Foundation
import UIKit

private var maxLengths = [UITextField: Int]()
private var minLengths = [UITextField: Int]()

extension UITextField {
    
    //MARK:- Maximum length
    @IBInspectable var maxLength: Int {
        get {
            guard let length = maxLengths[self] else {
                return 100
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            addTarget(self, action: #selector(fixMax), for: .editingChanged)
        }
    }
    @objc func fixMax(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedTo(length: maxLength)
    }
    
    //MARk:- Minimum length
    @IBInspectable var minLegth: Int {
        get {
            guard let l = minLengths[self] else {
                return 0
            }
            return l
        }
        set {
            minLengths[self] = newValue
            addTarget(self, action: #selector(fixMin), for: .editingChanged)
        }
    }
    @objc func fixMin(textField: UITextField) {
        let text = textField.text
        textField.text = text?.safelyLimitedFrom(length: minLegth)
    }
}

extension String {
    func safelyLimitedTo(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func safelyLimitedFrom(length n: Int) -> String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}
