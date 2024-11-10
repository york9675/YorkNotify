//
//  IconView.swift
//  YorkNotify
//
//  Created by York on 2024/10/1.
//

import Foundation
import SwiftUI

struct IconView: View {
   @AppStorage("customColor") private var customColorHex: String = ""

    var customColor: Color {
        Color(hex: customColorHex) ?? .blue
    }
    
    @State private var selectedIcon: AppIcon = .default
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    Image(systemName: "square.grid.2x2.fill")
                        .resizable()
                        .foregroundColor(customColor)
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 8)
                    
                    Text("App Icon")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    Text("Here, you have the option to personalize your app experience by selecting your preferred app icon.\n\nChoose from a variety of available icons to customize the look and feel of the app on your device. Once you've made your selection, the app icon will automatically update, reflecting your choice instantly. This allows you to tailor your app's appearance to match your personal style or preferences, giving you more control over your user experience.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            Section(header: Text("Select the app icon you want to change")) {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        updateIcon()
                    }) {
                        HStack {
                            icon.icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(icon.description)
                                .font(.body)
                            Spacer()
                            if selectedIcon == icon {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(customColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getCurrentIcon()
        }
    }
    
    private func getCurrentIcon() {
        if let iconName = UIApplication.shared.alternateIconName {
            selectedIcon = AppIcon(rawValue: iconName) ?? .default
        } else {
            selectedIcon = .default
        }
    }
    
    private func updateIcon() {
        print("Attempting to update icon to: \(selectedIcon.name ?? "default")")
        CommonUtils.updateAppIcon(with: selectedIcon.name)
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
