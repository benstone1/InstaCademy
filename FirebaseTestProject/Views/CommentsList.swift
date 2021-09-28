//
//  CommentsList.swift
//  FirebaseTestProject
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentsList

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
            case let .error(error):
                EmptyListView(
                    title: "Cannot Load Comments",
                    message: error.localizedDescription,
                    retryAction: { viewModel.loadComments() }
                )
            case .empty:
                EmptyListView(
                    title: "No Comments",
                    message: "Be the first to leave a comment."
                )
            case let .loaded(comments):
                List(comments) { comment in
                    CommentRow(viewModel: viewModel.makeCommentRowViewModel(for: comment))
                }
            }
        }
        .animation(.default, value: viewModel.comments)
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                NewCommentForm(viewModel: viewModel.makeCommentFormViewModel())
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CommentsList_Previews: PreviewProvider {
    static var previews: some View {
        CommentsPreview(state: .loaded(Comment.testComments))
        CommentsPreview(state: .empty)
        CommentsPreview(state: .error)
        CommentsPreview(state: .loading)
    }
    
    private struct CommentsPreview: View {
        let state: Loadable<[Comment]>
        
        var body: some View {
            NavigationView {
                CommentsList(viewModel: CommentViewModel(commentService: CommentServiceStub(state: state)))
            }
        }
    }
}
#endif
