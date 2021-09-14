//
//  NewPostForm.swift
//  NewPostForm
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    let submitAction: (Post.Partial) async throws -> Void
    
    @State private var post = Post.Partial()
    @StateObject private var submitTask = TaskViewModel()
    @FocusState private var isShowingKeyboard: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $post.title)
                }
                Section("Content") {
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                ChooseImageSection(selection: $post.image)
                Button("Submit", action: submitPost)
            }
            .alert("Cannot Submit Post", isPresented: $submitTask.isError, presenting: submitTask.error) { error in
                Text(error.localizedDescription)
            }
            .disabled(submitTask.isInProgress)
            .focused($isShowingKeyboard)
            .navigationTitle("New Post")
            .onSubmit(submitPost)
            .toolbar {
                CloseButton(action: dismiss.callAsFunction)
            }
        }
    }
    
    private func submitPost() {
        isShowingKeyboard = false
        submitTask.perform {
            try await submitAction(post)
            dismiss()
        }
    }
}

// MARK: - Subviews

private extension NewPostForm {
    struct ChooseImageSection: View {
        @Binding var selection: UIImage?
        @State private var showChooseImageSource = false
        @State private var imageSourceType: ImagePickerView.SourceType?
        
        var body: some View {
            Section("Image") {
                if let image = selection {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    Button("Change Image", action: {
                        showChooseImageSource = true
                    })
                } else {
                    Button("Select Image", action: {
                        showChooseImageSource = true
                    })
                }
            }
            .confirmationDialog("Choose Image", isPresented: $showChooseImageSource) {
                Button("Choose from Library", action: {
                    imageSourceType = .photoLibrary
                })
                Button("Take Photo", action: {
                    imageSourceType = .camera
                })
                if selection != nil {
                    Button("Remove Image", role: .destructive, action: {
                        selection = nil
                    })
                }
            }
            .sheet(item: $imageSourceType) {
                ImagePickerView(sourceType: $0, selection: $selection)
            }
        }
    }
    
    struct CloseButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Label("Close", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .font(.title2)
            .foregroundColor(.gray)
        }
    }
}

// MARK: - Previews

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(previewPost: Post.Partial(
            title: "Lorem ipsum",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            image: UIImage(named: "ProfileImagePlaceholder")
        ))
        NewPostForm(previewPost: Post.Partial())
    }
}

private extension NewPostForm {
    init(previewPost: Post.Partial) {
        self.submitAction = { _ in await Task.sleep(1_000_000_000) }
        self.post = previewPost
    }
}
