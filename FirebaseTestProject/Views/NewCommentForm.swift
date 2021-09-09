//
//  NewCommentForm.swift
//  NewCommentForm
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

struct NewCommentForm: View {
    let submitAction: (String) async throws -> Void
    
    @State private var comment = ""
    @StateObject private var submitTask = TaskViewModel()
    
    var body: some View {
        HStack {
            TextField("Comment", text: $comment)
            if submitTask.isInProgress {
                ProgressView()
            } else {
                Button(action: handleSubmit) {
                    Label("Post", systemImage: "paperplane")
                }
                .disabled(comment.isEmpty)
            }
        }
        .disabled(submitTask.isInProgress)
        .onSubmit(handleSubmit)
        .alert("Cannot Post Comment", isPresented: $submitTask.isError, presenting: submitTask.error) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func handleSubmit() {
        submitTask.run {
            try await submitAction(comment)
            comment = ""
        }
    }
}

struct NewCommentForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Preview")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NewCommentForm(submitAction: { _ in })
                    }
                }
        }
    }
}
