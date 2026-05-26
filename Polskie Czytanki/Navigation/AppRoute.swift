//
//  AppRoute.swift
//  Polskie Czytanki
//

import Foundation

enum AppRoute: Hashable {
    case stories
    case settings
    case story(Story)
}
