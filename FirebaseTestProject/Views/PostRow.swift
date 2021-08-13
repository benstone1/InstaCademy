//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    @EnvironmentObject var signInViewModel: SignInViewModel
    @ObservedObject var postData: PostData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.title)
                .padding(.bottom, 8)
            Text(post.text)
                .font(.body)
                .padding(.bottom, 8)
            HStack {
                Text(post.author)
                if post.author == signInViewModel.getUser() {
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
