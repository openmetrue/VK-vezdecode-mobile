//
//  MusicPlayer.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import Foundation
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    var player = AVAudioPlayer()
    func playSoundEffect() {
        do {
            player = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Digital", withExtension: "mp3")!)
            player.play()
        } catch {
            fatalError("Cannot play music")
        }
    }
}
