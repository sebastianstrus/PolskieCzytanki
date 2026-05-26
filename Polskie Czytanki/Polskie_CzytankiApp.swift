//
//  Polskie_CzytankiApp.swift
//  Polskie Czytanki
//

import SwiftUI

@main
struct Polskie_CzytankiApp: App {
    @State private var repository = StoryRepository()
    @State private var progress = ProgressStore()
    @State private var settings = SettingsStore()
    @State private var audio = AudioPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(repository)
                .environment(progress)
                .environment(settings)
                .environment(audio)
                .tint(Color(red: 0.96, green: 0.31, blue: 0.51))
        }
    }
}
