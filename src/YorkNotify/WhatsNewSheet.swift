//
//  WhatsNewSheet.swift
//  YorkNotify
//
//  Created by York on 2024/10/3.
//

import Foundation
import SwiftUI

let whatNewVersion = "4"

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
            
            Text("What's New?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(appVersion)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "applewatch")
                    .font(.system(size: 32))
                    .foregroundColor(customColor)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Redesigned watchOS App")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Enjoy a refreshed look for the watchOS app.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "person.crop.rectangle")
                    .font(.system(size: 32))
                    .foregroundColor(customColor)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Redesigned Info Pages")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Enjoy a refreshed look for the Acknowledgements and About Developer pages.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 32))
                    .foregroundColor(customColor)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Organized Notifications")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Now the home tab list will group notifications by date.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 32))
                    .foregroundColor(customColor)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Bug Fixes")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Other minor modifications and bug fixes to make this app better!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            Spacer()
            
            Button("Full Changelog...") {
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
                    Text("Continue")
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
