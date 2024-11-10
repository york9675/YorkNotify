//
//  WhatsNewSheet.swift
//  YorkNotify
//
//  Created by York on 2024/10/3.
//

import Foundation
import SwiftUI

let whatNewVersion = "2"

struct WhatsNewSheet: View {
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
            
            // Feature 1
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "applewatch")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Apple Watch Support")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("The new Apple Watch support allows you to conveniently view all scheduled notifications directly on your wrist!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        
            // Feature 2
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("iOS 18 Support")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Added support for iOS/iPadOS 18, including icon for dark and tinted modes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            // Feature 3
            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
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
                .background(Color.blue)
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
