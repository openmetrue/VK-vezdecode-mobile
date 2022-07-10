//
//  API.swift
//  Cats
//
//  Created by Mark Khmelnitskii on 10.04.2022.
//

import Foundation
import Combine

enum API {
    static private let agent = Agent()
    static private let base = URL(string: "https://pokeapi.co/api/v2")!
}

extension API {
    static func searchPokemonByID(_ id: Int) -> AnyPublisher<PokemonModel, Error> {
        let url = base.appendingPathComponent("/pokemon/\(id)") // Need "sprites and name"
        return agent.run(url: url)
    }
    static func getPokemonColorByID(_ id: Int) -> AnyPublisher<PokemonSpeciesModel, Error> {
        let url = base.appendingPathComponent("/pokemon-species/\(id)") // Need "color"
        return agent.run(url: url)
    }
    static func getAllColors() -> AnyPublisher<PokemonColorsModel, Error> {
        let url = base.appendingPathComponent("/pokemon-color") // Need "color"
        return agent.run(url: url)
    }
}
