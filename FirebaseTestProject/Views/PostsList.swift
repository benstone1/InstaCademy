//
//  PostsList.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - PostsList

struct PostsList: View {
    @StateObject var viewModel: PostViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        Group {
            switch viewModel.posts {
            case .loading:
                ProgressView()
            case let .error(error):
                EmptyListView(
                    title: "Cannot Load Posts",
                    message: error.localizedDescription,
                    retryAction: { viewModel.loadPosts() }
                )
            case .empty:
                EmptyListView(
                    title: "No Posts",
                    message: "There aren’t any posts here."
                )
            case let .loaded(posts):
                ScrollView {
                    ForEach(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(viewModel: viewModel.makePostRowViewModel(for: post))
                            if post != posts.last {
                                Divider()
                            }
                        }
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .animation(.default, value: viewModel.posts)
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.loadPosts()
        }
    }
}

extension PostsList {
    static func withNavigationView(viewModel: PostViewModel) -> some View {
        NavigationView {
            PostsList(viewModel: viewModel)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsPreview(state: .loaded(Post.testPosts))
        PostsPreview(state: .empty)
        PostsPreview(state: .error)
        PostsPreview(state: .loading)
    }
    
    @MainActor
    private struct PostsPreview: View {
        let state: Loadable<[Post]>
        
        var body: some View {
            NavigationView {
                PostsList(viewModel: PostViewModel(postService: PostServiceStub(state: state)))
            }
        }
    }
}
#endif
