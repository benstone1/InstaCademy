//
//  NewCommentForm.swift
//  NewCommentForm
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

struct NewCommentForm: View {
    let submitAction: (Comment.Partial) async throws -> Void
    
    @State private var comment = Comment.Partial()
    @StateObject private var submitTask = TaskViewModel()
    
    var body: some View {
        HStack {
            TextField("Comment", text: $comment.content)
            if submitTask.isInProgress {
                ProgressView()
            } else {
                Button(action: handleSubmit) {
                    Label("Post", systemImage: "paperplane")
                }
                .disabled(comment.content.isEmpty)
            }
        }
        .disabled(submitTask.isInProgress)
        .onSubmit(handleSubmit)
        .alert("Cannot Post Comment", isPresented: $submitTask.isError, presenting: submitTask.error) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func handleSubmit() {
        submitTask.perform {
            try await submitAction(comment)
            comment = .init()
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
