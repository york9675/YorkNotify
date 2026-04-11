//
//  SettingsView.swift
//  YorkNotifyWatch Watch App
//
//  Created by York on 2025/1/20.
//

import Foundation
import SwiftUI

struct SettingsView: View {

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
