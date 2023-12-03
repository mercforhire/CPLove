//
//  Array+Extensions.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-27.
//

import Foundation
import UIKit

extension Array where Element: UIView {
    func getElementOf(tag: Int) -> Element? {
        let found = self.filter { $0.tag == tag }
        return found.first
    }
}
