//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData: PostData
    @StateObject private var navigation = NavigationViewModel()
    @State private var searchText = ""
    @Environment(\.user) private var user
    
    enum Route: Equatable {
        case comments(Post)
    }
  
    var body: some View {
        NavigationView {
            List(postData.posts) { post in
                if searchText.isEmpty || post.contains(searchText) {
                    PostRow(
                        post: post,
                        route: $navigation.route,
                        favoriteAction: postData.favoriteAction(for: post),
                        deleteAction: postData.deleteAction(for: post)
                    )
                }
            }
            .searchable(text: $searchText)
            .refreshable {
                await postData.loadPosts()
            }
            .navigationTitle("Posts")
            .onAppear {
                Task {
                    await postData.loadPosts()
                }
            }
            .background {
                NavigationLink(isActive: $navigation.isActive) {
                    switch navigation.route {
                    case .none:
                        EmptyView()
                    case let .comments(post):
                        CommentsList(viewModel: postData.commentViewModel(for: post))
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
        PostsList(postData: .init(user: .testUser))
    }
}
