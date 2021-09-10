//
//  CommentsList.swift
//  CommentsList
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentsList

struct CommentsList: View {
    @ObservedObject var viewModel: CommentViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingScreen
            case .error:
                errorScreen
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
    
    var errorScreen: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Cannot Load Comments")
                .font(.title2)
                .fontWeight(.semibold)
            Button(action: {
                viewModel.loadComments()
            }) {
                Text("Try Again")
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(Color.gray)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
            }
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
            NewCommentForm(submitAction: viewModel.submitComment(_:))
        }
    }
}

// MARK: - Preview

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
