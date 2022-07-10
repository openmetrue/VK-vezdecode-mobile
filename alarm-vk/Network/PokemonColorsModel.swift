//
//  PokemonColorsModel.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import Foundation

struct PokemonColorsModel: Codable {
    let results: [Result]
}

struct Result: Codable {
    let name: String
}
