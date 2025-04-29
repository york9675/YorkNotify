//
//  WhatsNewSheet.swift
//  YorkNotify
//
//  Created by York on 2024/10/3.
//

import Foundation
import SwiftUI

let whatNewVersion = "5"

struct WhatsNewSheet: View {
    @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }

    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            Text(String(localized: "What's New?"))
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(appVersion)
                .foregroundColor(.secondary)

            Spacer()

            FeatureRow(
                systemImage: "clock.arrow.circlepath",
                title: String(localized: "Notification History"),
                description: String(localized: "Added notification history."),
                color: customColor
            )

            FeatureRow(
                systemImage: "ladybug.fill",
                title: String(localized: "Bug Fixes"),
                description: String(localized: "Other minor modifications and bug fixes to make this app better!"),
                color: customColor
            )

            Spacer()

            Button(String(localized: "Full Changelog...")) {
                if let url = URL(string: "https://github.com/york9675/YorkNotify/releases/tag/\(appVersion)") {
                    openURL(url)
                }
            }
            .padding(.bottom, 10)

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Spacer()
                    Text(String(localized: "Continue"))
                        .bold()
                    Image(systemName: "arrow.forward")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(customColor)
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

struct FeatureRow: View {
    let systemImage: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 25) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 40, alignment: .center)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}

#Preview {
    WhatsNewSheet()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
