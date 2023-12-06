//
//  DependenciesExtraAppApp.swift
//  DependenciesExtraApp
//
//  Created by arasan01 on 2023/12/06.
//

import SwiftUI
import DependenciesExtrasMacros

@main
struct DependenciesExtraAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(model: ContentViewModel())
        }
    }
}
