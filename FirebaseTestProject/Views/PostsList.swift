//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel: PostViewModel
    
    @Environment(\.user) private var user
    
    @State private var searchText = ""
    @State private var showNewPostForm = false
    
    @State private var route: Route? {
        didSet { hasActiveRoute = route != nil }
    }
    @State private var hasActiveRoute = false
    
    enum Route: Equatable {
        case comments(Post)
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.posts {
                case .loading:
                    ProgressView()
                        .onAppear {
                            viewModel.loadPosts()
                        }
                case .error:
                    ErrorView(title: "Cannot Load Posts", retryAction: {
                        viewModel.loadPosts()
                    })
                case let .loaded(posts) where posts.isEmpty:
                    EmptyListView(
                        title: "No Posts",
                        message: "There aren’t any posts here."
                    )
                case let .loaded(posts):
                    List(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(
                                post: post,
                                route: $route,
                                favoriteAction: viewModel.favoriteAction(for: post),
                                deleteAction: viewModel.deleteAction(for: post)
                            )
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .searchable(text: $searchText)
            .refreshable {
                await viewModel.refreshPosts()
            }
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showNewPostForm) {
                NewPostForm(submitAction: viewModel.submitPost(_:))
            }
            .background {
                NavigationLink(isActive: $hasActiveRoute) {
                    switch route {
                    case .none:
                        EmptyView()
                    case let .comments(post):
                        CommentsList(viewModel: makeCommentViewModel(for: post))
                    }
                } label: {
                    EmptyView()
                }
            }
        }
    }
    
    private func makeCommentViewModel(for post: Post) -> CommentViewModel {
        let postService = PostService(user: user)
        let commentService = CommentService(post: post, postService: postService)
        return CommentViewModel(commentService: commentService)
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList(viewModel: PostViewModel(postService: PostService(user: .testUser)))
    }
}
