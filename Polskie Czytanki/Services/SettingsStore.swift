//
//  SettingsStore.swift
//  Polskie Czytanki
//

import Foundation

@Observable
final class SettingsStore {
    private let showPlayButtonKey = "showPlayButton"

    var showPlayButton: Bool {
        didSet { UserDefaults.standard.set(showPlayButton, forKey: showPlayButtonKey) }
    }

    init() {
        if UserDefaults.standard.object(forKey: showPlayButtonKey) == nil {
            UserDefaults.standard.set(true, forKey: showPlayButtonKey)
        }
        self.showPlayButton = UserDefaults.standard.bool(forKey: showPlayButtonKey)
    }
}
