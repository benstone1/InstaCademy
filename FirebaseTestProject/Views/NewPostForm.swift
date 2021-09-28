//
//  NewPostForm.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    @StateObject var viewModel: PostFormViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $viewModel.editable.title)
                }
                Section("Content") {
                    TextEditor(text: $viewModel.editable.content)
                        .multilineTextAlignment(.leading)
                }
                ChooseImageSection(selection: $viewModel.editable.image)
                SubmitButton(action: handleSubmit)
            }
            .onSubmit(handleSubmit)
            .animation(.default, value: viewModel.isLoading)
            .disabled(viewModel.isLoading)
            .alert("Cannot Submit Post", isPresented: $viewModel.error.exists, presenting: viewModel.error, actions: { _ in }) {
                Text($0.localizedDescription)
            }
            .navigationTitle("New Post")
        }
    }
    
    private func handleSubmit() {
        viewModel.submit()
    }
}

// MARK: - ChooseImageSection

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
}

// MARK: - SubmitButton

private extension NewPostForm {
    struct SubmitButton: View {
        let action: () -> Void
        
        @Environment(\.isEnabled) private var isEnabled
        
        var body: some View {
            Button(action: action) {
                Group {
                    if isEnabled {
                        Text("Submit Post")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.accentColor)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(viewModel: PostFormViewModel(submitAction: { _ in }))
    }
}
#endif
