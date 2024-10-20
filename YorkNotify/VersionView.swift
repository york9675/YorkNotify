//
//  VersionView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct VersionView: View {
    @State private var showWhatsNew = false
    
    @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }

    @Environment(\.openURL) private var openURL
    @StateObject private var appState = AppState()
    @AppStorage("autoCheckUpdates") private var autoCheckUpdates = true
    
    enum UpdateAlertType: Identifiable {
        case latest, update, error
        
        var id: String {
            switch self {
            case .latest: return "latest"
            case .update: return "update"
            case .error: return "error"
            }
        }
    }
    
    @State private var alertType: UpdateAlertType? = nil
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .foregroundColor(customColor)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Version")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Access comprehensive details about the current software version, including a complete update log outlining new features, improvements, and bug fixes.\n\nAdditionally, you can easily report bugs using the button below.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            
            Section {
                Button(action: {
                    showWhatsNew = true
                }) {
                    Label("What's New?", systemImage: "sparkles")
                }
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewSheet()
                }
            }
            
            Section(header: Text("Check for updates"), footer: Text("When enabled, this app will automatically check if new updates are available from GitHub on startup.")) {
                Toggle("Check for Updates Automatically", isOn: $autoCheckUpdates)
                    .tint(.green)
                    .onChange(of: autoCheckUpdates) { value in
                        UserDefaults.standard.set(value, forKey: "autoCheckUpdates")
                    }
                
                Button(action: {
                    checkForUpdates()
                }) {
                    Label("Check for Updates Now", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            Section {
                Button(action: {
                    if let url = URL(string: "https://forms.gle/o1hFjy4q98Ua1H7L7") {
                        openURL(url)
                    }
                }) {
                    Label("Bug Report", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(item: $alertType) { alert in
            switch alert {
            case .update:
                return Alert(
                    title: Text("Update Available"),
                    message: Text("A new version \(appState.latestVersion ?? "unknown") is available, go to GitHub to download and install the latest version."),
                    dismissButton: .default(Text("OK"))
                )
            case .latest:
                return Alert(
                    title: Text("No Updates Available"),
                    message: Text("This app is on the latest version, well done!"),
                    dismissButton: .default(Text("OK"))
                )
            case .error:
                return Alert(
                    title: Text("Error"),
                    message: Text("An error occurred while checking for updates. Please check your network connection and try again."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle(appVersion)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func checkForUpdates() {
        fetchLatestVersion { latestVersion in
            DispatchQueue.main.async {
                if let latestVersion = latestVersion {
                    appState.latestVersion = latestVersion
                    if isNewVersionAvailable(currentVersion: appVersion, latestVersion: latestVersion) {
                        alertType = .update
                    } else {
                        alertType = .latest
                    }
                } else {
                    alertType = .error
                }
            }
        }
    }
}

#Preview {
    VersionView()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
