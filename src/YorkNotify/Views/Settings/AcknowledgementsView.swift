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
        NavigationStack {
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
            }
            .formStyle(.grouped)
            .navigationTitle("Acknowledgements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        } else {
                            Text("Done")
                                .bold()
                        }
                    }
                    .tint(.primary)
                    .accessibilityLabel("Done")
                }
            }
        }
    }
}

#Preview {
    AcknowledgementsView()
}

/*
░░░░░██████╗░░██████╗░░░░░
░░░░██╔════╝░██╔════╝░░░░░
░░░░██║░░██╗░██║░░██╗░░░░░
░░░░██║░░╚██╗██║░░╚██╗░░░░
░░░░╚██████╔╝╚██████╔╝░░░░
░░░░░╚═════╝░░╚═════╝░░░░░
*/
