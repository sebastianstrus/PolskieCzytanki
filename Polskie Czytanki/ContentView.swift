//
//  ContentView.swift
//  Polskie Czytanki
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environment(StoryRepository())
        .environment(ProgressStore())
        .environment(SettingsStore())
        .environment(AudioPlayer())
}
