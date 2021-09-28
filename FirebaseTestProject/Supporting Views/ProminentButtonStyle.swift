//
//  ProminentButtonStyle.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/26/21.
//

import SwiftUI

// MARK: - ButtonStyle

extension ButtonStyle where Self == ProminentButtonStyle {
    static var prominent: ProminentButtonStyle {
        ProminentButtonStyle()
    }
}

// MARK: - ProminentButtonStyle

struct ProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if isEnabled {
                configuration.label
            } else {
                ProgressView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.accentColor)
        .cornerRadius(15)
        .animation(.default, value: isEnabled)
    }
}

// MARK: - Previews

#if DEBUG
struct ProminentButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProminentButtonPreview(disabled: false)
        ProminentButtonPreview(disabled: true)
    }
    
    private struct ProminentButtonPreview: View {
        let disabled: Bool
        
        var body: some View {
            Button("Sign In", action: {})
                .buttonStyle(.prominent)
                .padding()
                .previewLayout(.sizeThatFits)
                .disabled(disabled)
        }
    }
}
#endif
