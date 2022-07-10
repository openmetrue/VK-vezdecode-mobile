//
//  PokemonSpeciesModel.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import Foundation

struct PokemonSpeciesModel: Codable {
    let color: Color
    let name: String
}

struct Color: Codable {
    let name: String
    let url: String
}
