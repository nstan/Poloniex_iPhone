//
//  AudioFunctions.swift
//  Poloniex
//
//  Created by Nikola Stan on 8/7/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//
//
//import Foundation
//import AVFoundation
//
//func playAudioWithVariablePitch (pitch: Float) {
//    audioPlayer.stop()
//    audioEngine.stop()
//    audioEngine.reset()
//    
//    var audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attachNode(audioPlayerNode)
//    
//    var changePitchEffect = AVAudioUnitTimePitch()
//    changePitchEffect.pitch = pitch
//    audioEngine.attachNote(changePitchEffect)
//    
//    audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
//    audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
//}
