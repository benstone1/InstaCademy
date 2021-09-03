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
    @State private var imageSourceType: ImagePickerView.SourceType?
    @State private var image: UIImage?
    
    @FocusState private var showingKeyboard: Bool
    
    @StateObject private var submitTask = TaskViewModel()
    
    @Environment(\.user) private var user
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .focused($showingKeyboard)
            TextEditor(text: $postContent)
                .focused($showingKeyboard)
                .multilineTextAlignment(.leading)
                .frame(width: 300, height: 300, alignment: .topLeading)
            uploadedImageOrPlaceholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200, alignment: .center)
            VStack {
                HStack(spacing: 30) {
                    Text("Attach Image")
                    Spacer()
                    Button {
                        imageSourceType = .photoLibrary
                    }  label: {
                        Label("Choose from Library", systemImage: "photo")
                    }
                    Button {
                        imageSourceType = .camera
                    }  label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                }
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
            }
            Button("Submit", action: submitPost)
        }
        .alert("Cannot Submit Post", isPresented: $submitTask.isError, presenting: submitTask.error) { error in
            Text(error.localizedDescription)
        }
        .sheet(item: $imageSourceType) {
            ImagePickerView(sourceType: $0, selection: $image)
        }
    }
    
    private var uploadedImageOrPlaceholder: Image {
        if let image = image {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    private func submitPost() {
        showingKeyboard = false
        let post = Post(title: title, text: postContent, author: user)
        submitTask.run {
            try await PostService(user: user).create(post, with: image)
            title = ""
            postContent = ""
            imageSourceType = nil
            image = nil
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm()
    }
}
