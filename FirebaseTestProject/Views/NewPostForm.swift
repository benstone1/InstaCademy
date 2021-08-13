//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct NewPostForm: View {
    @State var postContent = ""
    @State var title = ""
    @FocusState private var submittedPost: Bool
    @EnvironmentObject var signInViewModel: SignInViewModel
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .focused($submittedPost)
            TextField("Post content", text: $postContent)
                .focused($submittedPost)
            Button("Submit") {
                submittedPost = false
                Task {
                    do {
                        try await PostService.upload(Post(title: title, text: postContent, author: signInViewModel.getUser()))
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm()
    }
}
