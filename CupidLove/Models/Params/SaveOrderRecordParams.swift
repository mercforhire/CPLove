//
//  SaveOrderRecordParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-24.
//

import Foundation

struct SaveOrderRecordParams {
    var currency: String
    var orderId: String
    var orderStatus: Int
    var productId: String
    var purchasePrice: Double
    var transactionDate: Date
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["currency"] = currency
        params["orderId"] = orderId
        params["orderStatus"] = orderStatus
        params["productId"] = productId
        params["purchasePrice"] = purchasePrice
        params["transactionDate"] = DateUtil.convert(input: transactionDate, outputFormat: .format4)
        return params
    }
}
