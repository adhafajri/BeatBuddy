//
//  AudioService.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation

import AVKit
import SwiftUI

class AudioService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var player: AVAudioPlayer?
    @Published private(set) var isPlaying: Bool = false {
        didSet{
            print("isPlaying", isPlaying)
        }
    }
    
    func delegatePlayer(delegate: any AVAudioPlayerDelegate) {
        player?.delegate = delegate
    }
    
    func startPlayer(name: String, isPreview: Bool = false) throws {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else{
            print("Resource not found: \(name)")
            return
        }
        
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
        isPlaying = true
    }
    
    func playAudio() {
        guard let player = player else{
            print("Instance of audio player not found")
            return
        }
        
        guard !player.isPlaying else {
            return
        }
        
        player.play()
        isPlaying = true
    }
    
    func stopAudio() {
        guard let player = player else{
            print("Instance of audio player not found")
            return
        }
        
        guard player.isPlaying else {
            return
        }
        
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Handle the music stop event here
        print("Music has stopped")
        isPlaying = false
    }
}
