//
//  FeedbackParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-23.
//

import Foundation

struct FeedbackParams {
    var feedback: String
    var isPositive: Bool
    var tags: [String]
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["feedback"] = feedback
        params["isPositive"] = isPositive
        params["tags"] = tags
        return params
    }
}
