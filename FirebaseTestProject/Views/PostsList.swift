//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var viewModel: PostViewModel
    @StateObject private var navigation = NavigationViewModel()
    @State private var searchText = ""
    @State private var showNewPostForm = false
    @Environment(\.user) private var user
    
    enum Route: Equatable {
        case comments(Post)
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                if searchText.isEmpty || post.contains(searchText) {
                    PostRow(
                        post: post,
                        route: $navigation.route,
                        favoriteAction: viewModel.favoriteAction(for: post),
                        deleteAction: viewModel.deleteAction(for: post)
                    )
                }
            }
            .searchable(text: $searchText)
            .refreshable {
                await viewModel.refreshPosts()
            }
            .navigationTitle("Posts")
            .onAppear {
                viewModel.loadPosts()
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
                NavigationLink(isActive: $navigation.isActive) {
                    switch navigation.route {
                    case .none:
                        EmptyView()
                    case let .comments(post):
                        CommentsList(viewModel: viewModel.commentViewModel(for: post))
                    }
                } label: {
                    EmptyView()
                }
            }
        }
    }
    
    private class NavigationViewModel: ObservableObject {
        @Published var route: Route? {
            didSet {
                isActive = route != nil
            }
        }
        @Published var isActive = false
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList(viewModel: PostViewModel(user: .testUser))
    }
}
