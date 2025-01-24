//
//  Untitled.swift
//  YorkNotify
//
//  Created by York on 2025/1/20.
//

import Foundation
import SwiftUI

struct AboutView: View {
    let appVersion = "v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown") + "-beta"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

    var body: some View {
        VStack(spacing: 16) {
            Text("YorkNotify")
                .font(.title)

            Text("By York")
                .font(.body)

            VStack(spacing: 4) {
                Text("Version: \(appVersion) (\(buildNumber))")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("About")
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
