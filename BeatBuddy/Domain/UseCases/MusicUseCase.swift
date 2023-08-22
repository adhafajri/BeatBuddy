//
//  MusicUseCase.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation

protocol MusicUseCaseProtocol {
    var audioService: AudioService { get }
    func playMusic(music: MusicModel) throws
    func stopMusic()
}

class MusicUseCase: MusicUseCaseProtocol {
    let audioService: AudioService
    
    init(audioService: AudioService) {
        self.audioService = audioService
    }
    
    func playMusic(music: MusicModel) throws {
        try audioService.startPlayer(name: music.name)
    }
    
    func stopMusic() {
        audioService.stopAudio()
    }
}
