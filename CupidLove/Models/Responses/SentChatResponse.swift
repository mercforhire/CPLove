//
//  SentChatResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-03.
//

import Foundation

struct SentChatData: Codable {
    var notificationId: String?
}

struct SentChatResponse: Codable {
    var code: Int
    var data: SentChatData?
    var message: String
    var succeed: Bool
}
