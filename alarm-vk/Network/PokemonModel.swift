//
//  PokemonModel.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import Foundation

struct PokemonModel: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
}

struct Sprites: Codable {
    let backDefault: String?
    let frontDefault: String?
    let other: Other?
    enum CodingKeys: String, CodingKey {
        case backDefault = "back_default"
        case frontDefault = "front_default"
        case other
    }
}

struct Other: Codable {
    let officialArtwork: OfficialArtwork?
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String?
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
