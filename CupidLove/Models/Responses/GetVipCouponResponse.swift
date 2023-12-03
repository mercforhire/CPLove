//
//  GetVipCouponResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-23.
//

import Foundation

struct CouponData: Codable {
    var identifier: String
    var createdDate: String?
    var day: Int?
    var isRedeemed: Bool
    var month: Int?
    var redeemDate: String?
    var updateDate: String?
    var userId: String?
    var vipCode: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case createdDate
        case day
        case isRedeemed
        case month
        case redeemDate
        case updateDate
        case userId
        case vipCode
    }
}

struct GetVipCouponResponse: Codable {
    var data: CouponData?
    var code: Int
    var message: String
    var succeed: Bool
}
