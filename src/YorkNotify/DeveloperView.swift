//
//  DeveloperView.swift
//  YorkNotify
//
//  Created by York on 2024/12/16.
//

import Foundation
import SwiftUI

struct DeveloperView: View {
    @Environment(\.openURL) private var openURL
    @State private var profileImage: Image? = nil
    
    var body: some View {
        Form {
            // Profile Section
            Section {
                HStack(spacing: 15) {
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 85, height: 85)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.primary.opacity(0.5), lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 85, height: 85)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("York")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("App Developer")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }
            
            // About Me Section
            Section(header: Text("About Me")) {
                Text("""
                When I started developing apps, I had a simple yet sincere goal: to create something genuinely helpful, and to offer it for free. In a world dominated by paid features and ads, I wanted to build tools that anyone could use without any cost, purely to make life more convenient. My apps have been ad-free, and some, like this app, are even open-source. I’ve always believed that even if my apps help just a small group of people, making their lives easier or more efficient, it would all be worth it.
                """)
                .font(.body)
                .multilineTextAlignment(.leading)
            }
            
            // Links Section
            Section(header: Text("Links")) {
                Button(action: {
                    if let url = URL(string: "https://york9675.github.io/website/") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("York Development", systemImage: "globe")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
                Button(action: {
                    if let url = URL(string: "https://github.com/york9675") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("GitHub", systemImage: "cat")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }
            
            // Donate Section
            Section(header: Text("Donate")) {
                Button(action: {
                    if let url = URL(string: "https://www.buymeacoffee.com/york0524") {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Label("Buy Me A Coffee", systemImage: "cup.and.saucer")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }
        }
        .navigationTitle("About York")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadProfileImage) // Load GitHub profile image
    }
    
    // Profile Image Loading with Caching
    private func loadProfileImage() {
        let cacheKey = "profileImage"
        
        // Try to retrieve the cached image
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let uiImage = UIImage(data: cachedData) {
            self.profileImage = Image(uiImage: uiImage)
            return
        }
        
        // If not cached, fetch the image from GitHub
        guard let url = URL(string: "https://github.com/york9675.png") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                // Cache the image
                UserDefaults.standard.set(data, forKey: cacheKey)
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }
        task.resume()
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
