//
//  CommentsList.swift
//  CommentsList
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

struct CommentsList: View {
    @StateObject var viewModel: CommentViewModel
    
    var body: some View {
        Group {
            switch viewModel.comments {
            case .loading:
                ProgressView()
                    .onAppear {
                        viewModel.loadComments()
                    }
            case .error:
                ErrorView(title: "Cannot Load Comments", retryAction: {
                    viewModel.loadComments()
                })
            case let .loaded(comments) where comments.isEmpty:
                EmptyListView(
                    title: "No Comments",
                    message: "Be the first to leave a comment."
                )
            case let .loaded(comments):
                List(comments) { comment in
                    CommentRow(comment: comment, deleteAction: viewModel.deleteAction(for: comment))
                }
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                NewCommentForm(submitAction: viewModel.submitComment(_:))
            }
        }
    }
}

struct CommentsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let postService = PostService(user: .testUser)
            let commentService = CommentService(post: .testPost, postService: postService)
            let viewModel = CommentViewModel(commentService: commentService)
            CommentsList(viewModel: viewModel)
        }
    }
}
