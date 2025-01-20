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
    @State private var showAcknowledgementsView = false
    @Environment(\.openURL) private var openURL

    // Check if the current platform is macOS (running with Mac Catalyst)
    private var isMacOS: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

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

                    if !isMacOS {
                        NavigationLink(destination: IconView()) {
                            Label("App Icon", systemImage: "square.grid.2x2")
                        }
                        NavigationLink(destination: LangView()) {
                            Label("Language", systemImage: "globe")
                        }
                    }

                }

                Section {
                    NavigationLink(destination: LabView()) {
                        Label("Lab", systemImage: "flask")
                    }
                }

                Section(header: Text("About"), footer: Text("© 2025 York Development")) {
                    NavigationLink(destination: HelpView()) {
                        Label("Help", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: VersionView()) {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text("\(appVersion) (\(buildNumber))")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        showAcknowledgementsView = true
                    }) {
                        Label("Acknowledgements", systemImage: "doc.text")
                    }
                    .sheet(isPresented: $showAcknowledgementsView) {
                        AcknowledgementsView()
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
            VStack {
                Image(systemName: "gear")
                    .padding(.bottom, 5)
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("Please select a setting first")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
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
