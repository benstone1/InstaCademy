//
//  EmptyListView.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/9/21.
//

import SwiftUI

// MARK: - EmptyListView

struct EmptyListView: View {
    let title: String
    let message: String
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Group {
                Text(message)
                    .multilineTextAlignment(.center)
                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        Text("Try Again")
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary))
                    }
                    .padding(.top)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            title: "Cannot Load Posts",
            message: "Missing or insufficient permissions.",
            retryAction: {}
        )
        EmptyListView(
            title: "No Comments",
            message: "Be the first to leave a comment."
        )
    }
}
#endif
