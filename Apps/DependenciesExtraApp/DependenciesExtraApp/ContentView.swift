//
//  ContentView.swift
//  DependenciesExtraApp
//
//  Created by arasan01 on 2023/12/06.
//

import SwiftUI
import DependenciesExtrasMacros

final class ContentViewModel: ObservableObject {
    
    @Published var label = "---"
    @Dependency(\.wrappedDataLoader) var wloader
    @Dependency(\.dataLoader) var loader
    static let url: URL = .documentsDirectory.appendingPathComponent(
        UUID().uuidString,
        conformingTo: .text
    )
    
    func tappedButton() {
        let data = loader.load(url: Self.url)
        
        guard let label = String(data: data, encoding: .utf8) else { return }
        self.label = label
    }
    
    func tappedWButton() {
        let data = wloader.load(url: Self.url)

        guard let label = String(data: data, encoding: .utf8) else { return }
        self.label = label
    }
}

struct ContentView: View {
    @StateObject var model: ContentViewModel
    var body: some View {
        VStack {
            Text(model.label)
            
            Button("Normal Load") { model.tappedButton() }
                .buttonStyle(.bordered)
            
            Button("Wrapped Load") { model.tappedWButton() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}


#Preview {
    ContentView(model: ContentViewModel())
}
