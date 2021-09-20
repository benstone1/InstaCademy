//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - PostsList

struct PostsList: View {
    @StateObject var viewModel: PostViewModel
    
    @State private var searchText = ""
    @State private var route: Route?
    
    enum Route: Equatable {
        case author(User), comments(Post)
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .onAppear {
                        viewModel.loadPosts()
                    }
            case .error:
                ErrorView(title: "Cannot Load Posts", retryAction: {
                    viewModel.loadPosts()
                })
            case .loaded where viewModel.posts.isEmpty:
                EmptyListView(
                    title: "No Posts",
                    message: "There aren’t any posts here."
                )
            case .loaded:
                List(viewModel.posts) { post in
                    if searchText.isEmpty || post.contains(searchText) {
                        PostRow(
                            post: post,
                            route: $route,
                            favoriteAction: viewModel.favoriteAction(for: post),
                            deleteAction: viewModel.deleteAction(for: post)
                        )
                    }
                }
                .refreshable {
                    await viewModel.refreshPosts()
                }
                .searchable(text: $searchText)
            }
        }
        .background {
            RouterView(route: $route)
        }
    }
}

// MARK: - Presenting Views

extension PostsList {
    struct MainView: View {
        let viewModel: PostViewModel
        @State private var showNewPostForm = false
        
        var body: some View {
            NavigationView {
                PostsList(viewModel: viewModel)
                    .navigationTitle("Posts")
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
            }
        }
    }
    
    struct FavoritesView: View {
        let viewModel: PostViewModel
        
        var body: some View {
            NavigationView {
                PostsList(viewModel: viewModel)
                    .navigationTitle("Favorites")
            }
        }
    }
}

// MARK: - RouterView

private extension PostsList {
    @MainActor struct RouterView: View {
        @Binding var route: PostsList.Route?
        @State private var isActive = false
        
        @Environment(\.user) private var user
        
        var body: some View {
            NavigationLink(isActive: $isActive) {
                switch route {
                case .none:
                    EmptyView()
                case let .author(author):
                    PostsList(viewModel: makePostViewModel(for: author))
                        .navigationTitle("\(author.name)’s Posts")
                case let .comments(post):
                    CommentsList(viewModel: makeCommentViewModel(for: post))
                }
            } label: {
                EmptyView()
            }
            .onChange(of: route) { route in
                isActive = route != nil
            }
            .onChange(of: isActive) { isActive in
                route = isActive ? route : nil
            }
        }
        
        private func makeCommentViewModel(for post: Post) -> CommentViewModel {
            let commentService = CommentService(post: post, user: user)
            return CommentViewModel(commentService: commentService)
        }
        
        private func makePostViewModel(for author: User) -> PostViewModel {
            let postService = PostService(user: user)
            return PostViewModel(postService: postService, filter: .author(author))
        }
    }
}

// MARK: - Preview

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList.MainView(viewModel: PostViewModel(postService: PostService(user: .testUser)))
    }
}
