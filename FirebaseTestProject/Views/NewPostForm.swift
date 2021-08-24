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
    @FocusState private var showingKeyboard: Bool
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .focused($showingKeyboard)
            TextField("Post content", text: $postContent)
                .focused($showingKeyboard)
            Button("Submit") {
                showingKeyboard = false
                Task {
                    do {
                        try await PostService.upload(Post(title: title, text: postContent, author: "Add Auth"))
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
