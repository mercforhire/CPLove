//
//  GetReviewsResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-20.
//

import Foundation

struct ReviewRecord: Codable {
    var identifier: String
    var content: String
    var rating: Int?
    var targetUserId: String
    var type: Int
    var userId: String
    var userInfoDto: [UserQuery]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case content
        case rating
        case targetUserId
        case type
        case userId
        case userInfoDto
    }
}

struct ReviewsRecords: Codable {
    var current: Int
    var records: [ReviewRecord]
    var size: Int
    var total: Int
}

struct GetReviewsResponse: Codable {
    var data: ReviewsRecords?
    var code: Int
    var message: String
    var succeed: Bool
}
