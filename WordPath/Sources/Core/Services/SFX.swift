//
//  SFX.swift
//  WordPath
//
//  Created by Jorge Jordán on 21/10/25.
//


import AudioToolbox

enum SFX {
    // Sonidos del sistema (evita assets)
    static func tick() { AudioServicesPlaySystemSound(1105) }    // tick
    static func blip() { AudioServicesPlaySystemSound(1104) }    // selección
    static func success() { AudioServicesPlaySystemSound(1111) } // éxito
    static func error() { AudioServicesPlaySystemSound(1073) }   // error
}
