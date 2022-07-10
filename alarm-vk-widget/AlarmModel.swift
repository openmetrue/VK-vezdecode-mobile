//
//  AlarmModel.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import Foundation

struct AlarmModel: Codable {
    let id: String
    let date: Date
    let active: Bool
    let days: [String]
}
