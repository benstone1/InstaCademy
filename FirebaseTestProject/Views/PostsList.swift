//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData = PostData()
    @State private var searchText = ""
    
    var body: some View {
        SearchBar(text: $searchText)
        NavigationView {
            List(postData.posts, id: \.text) { post in
                if searchText.isEmpty || post.contains(searchText) {
                    PostRow(post: post)
                }
            }
            .refreshable {
                await postData.loadPosts()
            }
            .navigationTitle("Posts")
            .onAppear {
                Task {
                    await postData.loadPosts()
                }
            }
        }
    }
}

struct PostsList_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
