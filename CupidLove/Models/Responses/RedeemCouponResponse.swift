//
//  RedeemCouponResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-05.
//

import Foundation

struct RedeemCouponResponse: Codable {
    var data: Product?
    var code: Int
    var message: String
    var succeed: Bool
}
