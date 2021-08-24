//
//  ContentView.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @StateObject var postData = PostData()
    
    var body: some View {
        NavigationView {
            List(postData.posts, id: \.text) { post in
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostsList()
    }
}
