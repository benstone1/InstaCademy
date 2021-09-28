//
//  NewCommentForm.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - NewCommentForm

struct NewCommentForm: View {
    @StateObject var viewModel: CommentFormViewModel
    
    var body: some View {
        HStack {
            TextField("Comment", text: $viewModel.editable.content)
            Button(action: handleSubmit) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Label("Post", systemImage: "paperplane")
                }
            }
        }
        .onSubmit(handleSubmit)
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .alert("Cannot Submit Comment", isPresented: $viewModel.error.exists, presenting: viewModel.error, actions: { _ in }) {
            Text($0.localizedDescription)
        }
    }
    
    private func handleSubmit() {
        viewModel.submit()
    }
}

// MARK: - Preview

#if DEBUG
struct NewCommentForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Preview")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NewCommentForm(viewModel: CommentFormViewModel(submitAction: { _ in }))
                    }
                }
        }
    }
}
#endif
