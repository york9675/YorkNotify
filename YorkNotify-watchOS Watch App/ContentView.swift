//
//  ContentView.swift
//  YorkNotify-watchOS Watch App
//
//  Created by York on 2024/9/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "wrench.and.screwdriver")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("YorkNotify for watchOS is coming soon!\n(Maybe...)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
