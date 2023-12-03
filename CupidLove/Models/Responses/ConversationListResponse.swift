//
//  ConversationListResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-03.
//

import Foundation

struct Conversation: Codable {
    var conversationId: String
    var isLikeEachOther: Bool?
    var latestChatMessage: ChatMsg?
    var targetUserInfo: UserQuery?
    var totalUnread: Int?
    var type: Int?
}

struct ConversationListList: Codable {
    var current: Int
    var records: [Conversation]
    var size: Int
    var total: Int
}

struct ConversationListResponse: Codable {
    var data: ConversationListList?
    var code: Int
    var message: String
    var succeed: Bool
}
