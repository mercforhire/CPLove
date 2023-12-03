//
//  SendChatMessageParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-03.
//

import Foundation

struct SendChatMsgParams {
    var isFunc: Bool
    var msgContent: String
    var targetUserId: String
    var userId: String
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["isFunc"] = isFunc
        params["msgContent"] = msgContent
        params["targetUserId"] = targetUserId
        params["userId"] = userId
        return params
    }
}

struct SaveChatMsgParams {
    var conversationId: String
    var content: String
    var isFunction: Bool
    var toUserId: String
    var pushContent: String
    var functionType: String?
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["conversationId"] = conversationId
        params["content"] = content
        params["isFunction"] = isFunction
        params["toUserId"] = toUserId
        params["pushContent"] = pushContent
        params["functionType"] = functionType
        return params
    }
}
