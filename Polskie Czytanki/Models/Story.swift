//
//  Story.swift
//  Polskie Czytanki
//

import Foundation

struct Story: Identifiable, Decodable, Hashable {
    let id: String
    let title: String
    let text: String
    let questions: [Question]

    var number: Int {
        let digits = id.drop(while: { !$0.isNumber })
        return Int(digits) ?? 0
    }

    var smallImageName: String { "pl\(number)" }
    var largeImageName: String { "image_\(number)" }
    var audioFileName: String { "pl\(number)" }
}

struct Question: Decodable, Hashable {
    let question: String
    let options: [String]
    let correctAnswer: String

    enum CodingKeys: String, CodingKey {
        case question
        case options
        case correctAnswer = "correct_answer"
    }
}

struct StoriesPayload: Decodable {
    let stories: [Story]
}
