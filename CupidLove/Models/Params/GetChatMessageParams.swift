//
//  GetChatMessageParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-03.
//

import Foundation

struct GetChatMessageParams {
    var current: Int
    var size: Int
    var targetUserId: String
    var userId: String
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["current"] = current
        params["size"] = size
        params["targetUserId"] = targetUserId
        params["userId"] = userId
        return params
    }
}
