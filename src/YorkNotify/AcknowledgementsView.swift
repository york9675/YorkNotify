//
//  AcknowledgementsView.swift
//  YorkNotify
//
//  Created by York on 2024/10/2.
//

import Foundation
import SwiftUI

struct AcknowledgementsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // Developer Section
                Section(header: Text("Developer")) {
                    NavigationLink(destination: DeveloperView()) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("App Developer")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("York")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Contributors Section
                Section(header: Text("Contributors")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Special Thanks To")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text("• York - UI/UX Design")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("• Google Translate - App Translation")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("• Lin_tsen - Testing and Feedback")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("• ChatGPT - Code Assistance")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Open-Source Project Section
                Section(header: Text("Open-Source Project")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("This app uses the following open-source project:")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Text("YorkNotify")
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        Text("Author: York")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("URL: https://github.com/york9675/YorkNotify")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("""
                        License:
                        
                        MIT License
                        
                        Copyright (c) 2024 York
                        
                        Permission is hereby granted, free of charge, to any person obtaining a copy
                        of this software and associated documentation files (the "Software"), to deal
                        in the Software without restriction, including without limitation the rights
                        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                        copies of the Software, and to permit persons to whom the Software is
                        furnished to do so, subject to the following conditions:
                        
                        The above copyright notice and this permission notice shall be included in all
                        copies or substantial portions of the Software.
                        
                        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                        SOFTWARE.
                        """)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Acknowledgements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
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
