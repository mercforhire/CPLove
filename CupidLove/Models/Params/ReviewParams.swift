//
//  ReviewParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-20.
//

import Foundation

struct ReviewParams: Codable {
    var identifier: String?
    var content: String
    var rating: Int?
    var targetUserId: String
    var type: CommentType
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        
        params["id"] = identifier
        params["content"] = content
        params["rating"] = rating
        params["targetUserId"] = targetUserId
        params["type"] = type.rawValue
        
        return params
    }
}
