//
//  WhatsNewSheet.swift
//  YorkNotify
//
//  Created by York on 2024/10/3.
//

import Foundation
import SwiftUI

let appVersion = "v2.2.1-beta"
let build = "36"

struct WhatsNewSheet: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            
            Text("What's New?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(appVersion)")
                .foregroundColor(.secondary)
            
            Spacer()

            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("New \"What's New\" Sheet")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("The new \"What's new\" sheet allows you to immediately see what new features have been added to this version after updating the app!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.teal)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Custom Color Scheme")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("You can now customize the app’s color scheme to better match your personal style.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "ipad.and.iphone")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Landscape, iPadOS Support")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Landscape display and iPadOS now have better support.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            HStack(alignment: .top, spacing: 25) {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
                
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
            .padding(.horizontal)
            
            Spacer()
            
            Button("Full Changelog...") {
                if let url = URL(string: "https://github.com/york9675/YorkNotify/releases/tag/\(appVersion)") {
                    openURL(url)
                }
            }
            
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
