//
//  UITableViewCell+Extensions.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-30.
//

import Foundation
import UIKit

extension UITableViewCell {
    func getTableView() -> UITableView? {
        var view = self.superview
        while view != nil && !(view is UITableView) {
            view = view?.superview
        }
        
        guard let tableView = view as? UITableView else { return nil }
        return tableView
    }
}
