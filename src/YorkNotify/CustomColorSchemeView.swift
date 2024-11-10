//
//  CustomColorSchemeView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct CustomColorSchemeView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "paintbrush.fill")
                        .font(.largeTitle)
                        .foregroundColor(customColor)
                        .padding(.bottom, 8)
                    
                    Text("Color Scheme")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    Text("Personalize and customize the theme colors for this app to match your style and preferences. Choose from a wide variety of color palettes or create your own unique combinations to enhance your user experience. Whether you prefer bold and vibrant tones or soft and subtle hues, the customization options allow you to fully express your individuality. Make the app truly yours by setting up a theme that reflects your personal aesthetic.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }

            Section {
                ColorPicker("Custom Color Scheme", selection: Binding(
                    get: { customColor },
                    set: { newColor in
                        customColorHex = newColor.toHex ?? ""
                    }
                ), supportsOpacity: false)
            }
            
            Section {
                Button(action: {
                    randomColor()
                }) {
                    Label("Random Color", systemImage: "dice")
                }
                
                Button(action: {
                    resetSettings()
                }) {
                    Label("Reset To Default", systemImage: "arrow.triangle.2.circlepath")
                }
            }
        }
        .navigationTitle("Color Scheme")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func randomColor() {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)

        let randomColor = Color(red: red, green: green, blue: blue)

        customColorHex = randomColor.toHex ?? ""
    }

    private func resetSettings() {
        customColorHex = ""
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
