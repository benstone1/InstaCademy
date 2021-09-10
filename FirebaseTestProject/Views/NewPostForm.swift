//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct NewPostForm: View {
    let submitAction: (Post.Partial) async throws -> Void
    
    @State private var post = Post.Partial()
    
    @State private var imageSourceType: ImagePickerView.SourceType?
    @FocusState private var showingKeyboard: Bool
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var submitTask = TaskViewModel()
    
    var body: some View {
        Form {
            TextField("Title", text: $post.title)
                .focused($showingKeyboard)
            TextEditor(text: $post.content)
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
            ImagePickerView(sourceType: $0, selection: $post.image)
        }
    }
    
    private var uploadedImageOrPlaceholder: Image {
        if let image = post.image {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    private func submitPost() {
        showingKeyboard = false
        submitTask.run {
            try await submitAction(post)
            dismiss()
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(submitAction: { _ in })
    }
}
