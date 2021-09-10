//
//  EmptyListView.swift
//  EmptyListView
//
//  Created by John Royal on 9/9/21.
//

import SwiftUI

struct EmptyListView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            title: "No Comments",
            message: "Be the first to leave a comment."
        )
    }
}
