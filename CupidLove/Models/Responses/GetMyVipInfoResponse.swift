//
//  GetMyVipInfoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-19.
//

import Foundation

struct GetMyVipInfo: Codable {
    var identifier: String
    var productInfo: String
    var amount: Int
    var detail: [String]
    var expireDate: String
    var iconName: String
    var imageName: String
    var imageUrl: String
    var name: String
    var price: Int
    var status: Int
    var type: Int
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case productInfo = "description"
        case amount
        case detail
        case expireDate
        case iconName
        case imageName
        case imageUrl
        case name
        case price
        case status
        case type
    }
}

struct GetMyVipInfoResponse: Codable {
    var data: GetMyVipInfo?
    var code: Int
    var message: String
    var succeed: Bool
}
