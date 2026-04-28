//
//  LangView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct LangView: View {
   @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }
    
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
        Form {
            Section {
                VStack(alignment: .leading) {
                    Image(systemName: "globe")
                        .resizable()
                        .foregroundColor(customColor)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 5)
                    
                    Text("Language")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)
                    
                    if !isMacOS {
                        Text("Please click the button below to jump to the system settings and tap \"Language\" to change your preferred App language.\n\nThe translation may use a large amount of machine translation and contain many errors or irrationalities. If there are any errors in the translation, please go to the GitHub Issues to report it. Thank you!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Please go to System Settings > General > Language & Region, scroll to the Applications section, and click Add (+). In the dialog, select YorkNotify from the app list, choose your preferred language from the dropdown menu, and click Add. Restart YorkNotify to apply the new language setting.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isMacOS {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }) {
                        Label("App Settings", systemImage: "gear")
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "https://github.com/york9675/YorkNotify/issues") {
                        openURL(url)
                    }
                }) {
                    Label("Translation problem report", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LangView()
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
