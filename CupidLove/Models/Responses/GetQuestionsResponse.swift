//
//  GetQuestionsResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-17.
//

import Foundation

struct QuestionAnswer: Equatable, Codable {
    var questionId: String
    var answer: String?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.questionId == rhs.questionId
    }
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["answer"] = answer != nil ? answer : NSNull()
        params["questionId"] = questionId
        return params
    }
}

struct QuestionData: Codable {
    var identifier: String
    var question: String?
    var order: Int?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case question = "description"
        case order
    }
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["id"] = identifier
        params["description"] = question
        params["order"] = order
        return params
    }
}

struct SaveQuestionResponse: Codable {
    var data: QuestionData?
    var code: Int
    var message: String
    var succeed: Bool
}

struct GetQuestionListResponse: Codable {
    var data: [QuestionData]?
    var code: Int
    var message: String
    var succeed: Bool
}
