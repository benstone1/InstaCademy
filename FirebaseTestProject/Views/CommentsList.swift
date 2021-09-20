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
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .onAppear {
                        viewModel.loadComments()
                    }
            case .error:
                ErrorView(title: "Cannot Load Comments", retryAction: {
                    viewModel.loadComments()
                })
            case .loaded where viewModel.comments.isEmpty:
                EmptyListView(
                    title: "No Comments",
                    message: "Be the first to leave a comment."
                )
            case .loaded:
                List(viewModel.comments) { comment in
                    CommentRow(comment: comment, deleteAction: viewModel.deleteAction(for: comment))
                }
                .refreshable {
                    await viewModel.refreshComments()
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
            let commentService = CommentService(post: .testPost, user: .testUser)
            let viewModel = CommentViewModel(commentService: commentService)
            CommentsList(viewModel: viewModel)
        }
    }
}
