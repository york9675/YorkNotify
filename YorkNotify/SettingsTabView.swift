//
//  SettingsTabView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct SettingsTabView: View {
    @Binding var selectedTheme: Theme
    @State private var showErrorAlert = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    Picker(selection: $selectedTheme, label: Label("Theme", systemImage: "moon")) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.localizedString).tag(theme)
                        }
                    }

                    NavigationLink(destination: CustomColorSchemeView()) {
                        Label("Color Scheme", systemImage: "paintbrush")
                    }

                    NavigationLink(destination: DefaultContentView()) {
                        Label("Default Content", systemImage: "character")
                    }

                    NavigationLink(destination: IconView()) {
                        Label("App Icon", systemImage: "square.grid.2x2")
                    }

                    NavigationLink(destination: LangView()) {
                        Label("Language", systemImage: "globe")
                    }
                }

                Section {
                    NavigationLink(destination: LabView()) {
                        Label("Lab", systemImage: "flask")
                    }
                }

                Section(header: Text("About"), footer: Text("© 2024 York Development")) {
                    NavigationLink(destination: HelpView()) {
                        Label("Help", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: AutherView()) {
                        HStack {
                            Label("Auther", systemImage: "person")
                            Spacer()
                            Text("York")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: VersionView()) {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text("\(appVersion) (\(build))")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Label("Feedback", systemImage: "info.bubble")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
