//
//  GetProductsResponses.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-23.
//

import Foundation

struct Product: Codable {
    var identifier: String
    var productDescription: String?
    var status: Int
    var type: Int
    var name: String
    var iconName: String?
    var imageName: String?
    var imageUrl: String?
    var detail: [String]?
    var price: Double
    var amount: Int
    
    var unit: String {
        if type == 0 {
            return "coins"
        } else if type == 1 {
            return "month"
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case productDescription = "description"
        case status
        case type
        case name
        case iconName
        case imageName
        case imageUrl
        case detail
        case price
        case amount
    }
    
    func toSaveOrderRecordParams(currency: String, orderId: String, orderStatus: Int) -> SaveOrderRecordParams {
        let params = SaveOrderRecordParams(currency: currency,
                                           orderId: orderId,
                                           orderStatus: orderStatus,
                                           productId: identifier,
                                           purchasePrice: price,
                                           transactionDate: Date())
        return params
        
    }
}

struct ProductsRecords: Codable {
    var current: Int
    var records: [Product]
    var size: Int
    var total: Int
}

struct ProductResponse: Codable {
    var data: ProductsRecords?
    var code: Int
    var message: String
    var succeed: Bool
}
