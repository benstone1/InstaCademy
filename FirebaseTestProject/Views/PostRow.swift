//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var postData: PostData
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.largeTitle)
                .padding()
            Text(post.text)
                .font(.body)
                .padding()
            HStack {
                Text(post.author)
                if post.author == authViewModel.getUser() {
                    Spacer()
                    Button {
                        Task {
                            do {
                                try await PostService.delete(post)
                            }
                            catch {
                                print(error)
                            }
                            await postData.loadPosts()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .foregroundColor(Color.red)
                            .frame(width: 15, height: 15)
                    }
                }
            }
            .padding(.bottom, 8)
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRow(post: Post.testPost, postData: PostData())
    }
}
