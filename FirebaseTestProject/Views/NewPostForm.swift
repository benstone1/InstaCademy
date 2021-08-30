//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct NewPostForm: View {
    @State private var title = "Title"
    @State private var postContent = "Post Content"
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
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                .frame(width: 300, height: 300, alignment: .topLeading)
                
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200, alignment: .center)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200, alignment: .center)
            }
            VStack {
                HStack {
                    Text("Attach image from:")
                        .foregroundColor(Color.blue)
                        .padding(.trailing, 30)
                    Button {
                        imageSourceType = .photoLibrary
                    }  label: {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 35, height: 25)
                            .padding(.trailing, 30)
                    }
                    Button {
                        imageSourceType = .camera
                    }  label: {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 35, height: 25)
                    }
                }
                .buttonStyle(.borderless)
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
    
    private func submitPost() {
        showingKeyboard = false
        let post = Post(title: title, text: postContent, author: user)
        submitTask.run {
            try await PostService.upload(post, with: image)
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
