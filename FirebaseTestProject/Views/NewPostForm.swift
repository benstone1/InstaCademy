//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct NewPostForm: View {
    @State private var title = ""
    @State private var postContent = ""
    @FocusState private var showingKeyboard: Bool
    @StateObject private var submitTask = TaskViewModel()
    @Environment(\.user) private var user
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .focused($showingKeyboard)
            TextField("Post content", text: $postContent)
                .focused($showingKeyboard)
            Button("Submit", action: submitPost)
        }
        .alert("Cannot Submit Post", isPresented: $submitTask.isError, presenting: submitTask.error) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func submitPost() {
        showingKeyboard = false
        let post = Post(title: title, text: postContent, author: user)
        
        submitTask.run {
            try await PostService.upload(post)
            title = ""
            postContent = ""
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm()
    }
}
