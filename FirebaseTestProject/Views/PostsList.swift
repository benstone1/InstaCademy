//
//  PostsList.swift
//  PostsList
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData = PostData()
    @State private var searchText: String = ""
    
    var body: some View {
        //Searchable Posts
        SearchBar(text: $searchText)
        let posts = searchText == "" ? postData.posts : postData.posts.filter({ $0.contains(searchText) })
        
        NavigationView {
            List(posts, id: \.text) { post in
                PostRow(post: post)
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
