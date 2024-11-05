//
//  AutherView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct AutherView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section(header: Text("About Me")) {
                Text("When I started developing apps, I had a simple yet sincere goal: to create something genuinely helpful, and to offer it for free. In a world dominated by paid features and ads, I wanted to build tools that anyone could use without any cost, purely to make life more convenient. My apps have been ad-free, and some, like this app, are even open-source. I’ve always believed that even if my apps help just a small group of people, making their lives easier or more efficient, it would all be worth it.")
            }
            
            Section(header: Text("Links")) {
                Button(action: {
                    if let url = URL(string: "https://github.com/york9675") {
                        openURL(url)
                    }
                }) {
                    Label("GitHub", systemImage: "cat")
                }
            }
            
            Section(header: Text("Donate")) {
                Button(action: {
                    if let url = URL(string: "https://www.buymeacoffee.com/york0524") {
                        openURL(url)
                    }
                }) {
                    Label("Buy Me A Coffee", systemImage: "cup.and.saucer")
                }
            }
        }
        .navigationTitle("York")
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
