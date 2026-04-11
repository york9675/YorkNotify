//
//  HelpView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct HelpView: View {
   @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }
    
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form{
            Section {
                VStack(alignment: .leading) {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .foregroundColor(customColor)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 5)
                    
                    Text("Help Center")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 5)
                    
                    Text("Welcome to the Help Center!\nHere, you’ll find everything you need to get the most out of this app. If you need further assistance, don’t hesitate to open a issue in GitHub.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Section(header: Text("Q: How to schedule notifications?")) {
                Text("Tap the \"+\" symbol in the upper right corner of the home tab, enter the notification title and content, finally set the time and click Save to schedule the notification.")
            }
            Section {
                Button(action: {
                    if let url = URL(string: "https://github.com/york9675/YorkNotify/issues") {
                        openURL(url)
                    }
                }) {
                    Label("Bug Report", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpView()
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
