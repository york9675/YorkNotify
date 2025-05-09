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
                VStack(alignment: .center) {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .foregroundColor(customColor)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 8)
                    
                    Text("Help Center")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    Text("Welcome to the Help Center!\n\nHere, you’ll find everything you need to get the most out of this app. If you need further assistance, don’t hesitate to fill the report form.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            Section(header: Text("Q: How to schedule notifications?")) {
                Text("Tap the \"+\" symbol in the upper right corner of the home tab, enter the notification title and content, finally set the time and click Save to schedule the notification.")
            }
            Section(header: Text("Q: Any other questions?")) {
                Text("Use our feedback form to get help!")
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
        .navigationTitle("Help Center")
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
