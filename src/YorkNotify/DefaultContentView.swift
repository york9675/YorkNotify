//
//  DefaultContentView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct DefaultContentView: View {
   @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }
    
    @AppStorage("defaultNotificationTitle") private var defaultTitle: String = "York Notify"
    @AppStorage("defaultNotificationContent") private var defaultContent: String = "Please remember."
    @AppStorage("showMissingInfoAlert") private var showMissingInfoAlert = true

    private let originalDefaultTitle = "York Notify"
    private let originalDefaultContent = "Please remember."

    var body: some View {
        Form {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "character")
                        .font(.largeTitle)
                        .foregroundColor(customColor)
                    
                    Text("Default Content")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Set the default notification content here.\n\nWhenever you create a new notification but leave certain fields empty, the app will automatically insert the default content you've defined here. This ensures that all notifications are complete and consistent, even if specific details are missing during creation.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            
            Section(header: Text("Default Notification Content")) {
                HStack {
                    Text("Default Title")
                    TextField("Title", text: $defaultTitle)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Default Text")
                    TextField("Text", text: $defaultContent)
                        .multilineTextAlignment(.trailing)
                }
                
                Button(action: {
                    resetToDefault()
                }) {
                    Label("Reset To Default", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            Section(header: Text("Alert"), footer: Text("If disabled, the default content will be automatically used without warning when creating notifications if information is missing.")) {
                Toggle("Show missing information alert", isOn: $showMissingInfoAlert)
                    .tint(.green)
            }
        }
        .navigationTitle("Default Content")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetToDefault() {
        defaultTitle = originalDefaultTitle
        defaultContent = originalDefaultContent
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
