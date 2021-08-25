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
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingScreen
            case .loaded where viewModel.comments.isEmpty:
                emptyScreen
            case .loaded:
                commentsScreen
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
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
                viewModel.loadComments()
            }
    }
    
    var emptyScreen: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("No Comments")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Be the first to leave a comment.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    var commentsScreen: some View {
        List(viewModel.comments) { comment in
            CommentRow(comment: comment, deleteAction: viewModel.deleteAction(for: comment))
        }
    }
    
    var newCommentForm: ToolbarItem<Void, NewCommentForm> {
        ToolbarItem(placement: .bottomBar) {
            NewCommentForm(submitAction: viewModel.submitComment(content:))
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
