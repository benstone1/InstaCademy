//
//  CommentsList.swift
//  CommentsList
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentsList

struct CommentsList: View {
    @ObservedObject var viewModel: CommentsViewModel
    
    @State private var commentsDidLoad = false
    @State private var error: PostService.CommentError? {
        didSet {
            hasError = error != nil
        }
    }
    @State private var hasError = false
    
    var body: some View {
        Group {
            if !commentsDidLoad {
                loadingScreen
            } else if viewModel.comments.isEmpty {
                emptyState
            } else {
                commentsList
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $hasError, error: error, actions: { _ in }) { error in
            Text(error.failureReason ?? "Sorry, something went wrong.")
        }
        .toolbar {
            newCommentForm
        }
    }
}

// MARK: - Subviews

private extension CommentsList {
    var loadingScreen: some View {
        ProgressView()
            .onAppear {
                performTask {
                    try await viewModel.loadComments()
                    commentsDidLoad = true
                }
            }
    }
    
    var emptyState: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("No Comments")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Be the first to leave a comment.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    var commentsList: some View {
        List(viewModel.comments) { comment in
            CommentRow(comment: comment, deleteAction: viewModel.canDelete(comment) ? {
                await perform {
                    try await viewModel.deleteComment(comment)
                }
            } : nil)
        }
    }
    
    var newCommentForm: ToolbarItem<Void, NewCommentForm> {
        ToolbarItem(placement: .bottomBar) {
            NewCommentForm(submitAction: { content in
                await perform {
                    try await viewModel.submitComment(content: content)
                }
            })
        }
    }
}

// MARK: - Utilities

private extension CommentsList {
    @discardableResult
    func perform(action: @escaping () async throws -> Void) async -> Bool {
        do {
            try await action()
            return true
        } catch {
            self.error = (error as? PostService.CommentError) ?? .unknown
            return false
        }
    }
    
    func performTask(action: @escaping () async throws -> Void) {
        Task {
            await perform(action: action)
        }
    }
}

// MARK: - Preview

struct CommentsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CommentsList(viewModel: .init(post: .testPost, user: .testUser))
        }
    }
}
