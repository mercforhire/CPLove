//
//  ChatMessage.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-03.
//

import Foundation

struct ChatMsg: Codable {
    var identifier: String
    var content: String
    var createdDate: String
    var fromUserId: String
    var isFunction: Bool
    var functionType: String?
    var read: Bool
    var toUserId: String
    var updateDate: String
    
    var timeStamp: Date? {
        return DateUtil.produceDate(dateString: updateDate, dateFormat: DateUtil.AppDateFormat.format7.rawValue)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case content
        case createdDate
        case fromUserId
        case isFunction
        case functionType
        case read
        case toUserId
        case updateDate
    }
}

struct ChatList: Codable {
    var current: Int
    var records: [ChatMsg]
    var size: Int
    var total: Int
}

struct ChatListData: Codable {
    var conversationId: String
    var chatPages: ChatList?
    var expiredDays: Int?
    var isLikeEachOther: Bool?
    var targetUserInfo: UserQuery?
    var totalUnread: Int?
    var type: Int?
}

struct ChatListResponse: Codable {
    var data: ChatListData?
    var code: Int
    var message: String
    var succeed: Bool
}
