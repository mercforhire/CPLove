//
//  ProfileQuestion.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import Foundation

struct UserProfileQuestionAndAnswer: Codable {
    var questionId: String
    var answer: String
    var question: String
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case question = "description"
        case answer
    }
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["questionId"] = questionId
        params["question"] = question
        params["answer"] = answer
        return params
    }
}
