//
//  LabView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct LabView: View {
    @AppStorage("customColor") private var customColorHex: String = ""

     var customColor: Color {
         Color(hex: customColorHex) ?? .blue
     }
    
    @AppStorage("enableExperimentalFeatures") private var enableExperimentalFeatures = false
    @AppStorage("enableTimeSensitiveNotifications") private var enableTimeSensitiveNotifications = false
    @AppStorage("enableCustomFrequency") private var enableCustomFrequency = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "flask.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color.purple)
                    
                    Text("Lab")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Enable Experimental Features to try out new, unfinished features that may not work as expected.\n\nThese features are in testing and could change or be removed in future updates. Use with caution, and expect occasional issues.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                Toggle("Enable Experimental Features", isOn: Binding(
                    get: { enableExperimentalFeatures },
                    set: { newValue in
                        enableExperimentalFeatures = newValue
                        if !newValue {
                            enableTimeSensitiveNotifications = false
                            enableCustomFrequency = false
                        }
                    }
                ))
                .tint(.green)
            }

            if enableExperimentalFeatures {
                Section {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color.yellow)
                        
                        VStack(alignment: .leading) {
                            Text("Time Sensitive Notifications")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Time Sensitive Notifications are a special category of alerts that can break through Focus modes or Do Not Disturb settings to deliver important information. When enabled, notifications marked as \"Time Sensitive Notifications\" will be treated with higher urgency and will be shown to the user even when their device is otherwise set to minimize interruptions.")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Toggle("Enable", isOn: $enableTimeSensitiveNotifications)
                        .tint(.green)
                }
                
                Section {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.largeTitle)
                            .foregroundColor(Color.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Custom Frequency")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Enable Custom Frequency to customize how often notifications are repeated. This allows you to choose the days of the week on which notifications should be sent regularly.")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Toggle("Enable", isOn: $enableCustomFrequency)
                        .tint(.green)
                        .disabled(true)
                }
                
            }
        }
        .navigationTitle("Lab")
        .navigationBarTitleDisplayMode(.inline)
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
