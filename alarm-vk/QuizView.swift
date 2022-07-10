//
//  QuizView.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: ViewModel
    var clouser: () -> Void
    @State var wrongText: [String] = []
    @State var rightText: String = ""
    var body: some View {
        VStack {
            Text("Чтобы разблокировать решите задачу:")
                .font(.title3)
                .padding(.top)
            HStack {
                if let images = viewModel.pokemonImages {
                    VStack {
                        if let front = images.frontDefault {
                            AsyncImage(url: URL(string: front)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .padding()
                        }
                        if let back = images.backDefault {
                            AsyncImage(url: URL(string: back)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .padding()
                        }
                    }
                    if let other = images.other,
                       let artBook = other.officialArtwork,
                       let front = artBook.frontDefault {
                        AsyncImage(url: URL(string: front)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                    }
                }
            }
            Text("Какого цвета этот покемон?")
                .bold()
                .padding()
            Spacer()
            LazyVGrid(columns: viewModel.columns, spacing: 25) {
                ForEach(viewModel.colors, id: \.self) { color in
                    Button {
                        answer(color, all: viewModel.colors, answer: viewModel.pokemonColor)
                    } label: {
                        Text(color)
                            .foregroundColor(wrongText.contains(color) ? .red : .accentColor)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(rightText == color ? .green : .clear))
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.getRandomPokemon()
        }
    }
    func answer(_ text: String, all: [String], answer: String) {
        switch text {
        case "SKIP":
            clouser()
        case "OTHER":
            if !all.contains(answer) {
                rightText = text
                clouser()
            } else {
                wrongText.append(text)
            }
        default:
            if text == answer {
                rightText = text
                clouser()
            } else {
                wrongText.append(text)
            }
        }
    }
}
