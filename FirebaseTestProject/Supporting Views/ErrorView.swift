//
//  ErrorView.swift
//  ErrorView
//
//  Created by John Royal on 9/9/21.
//

import SwiftUI

struct ErrorView: View {
    let title: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Button(action: retryAction) {
                Text("Try Again")
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(Color.gray)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(title: "Cannot Load Comments", retryAction: {})
    }
}
