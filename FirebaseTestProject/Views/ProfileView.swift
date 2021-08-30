//
//  ProfileView.swift
//  ProfileView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let updateImageAction: (UIImage) async throws -> Void
    let signOutAction: () async throws -> Void
    
    @State private var showChooseImageSource = false
    @State private var imageSourceType: ImagePickerView.SourceType?
    @State private var newImageCandidate: UIImage?
    
    @StateObject private var uploadImageTask = TaskViewModel()
    @StateObject private var signOutTask = TaskViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            if let image = newImageCandidate {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                HStack(alignment: .center, spacing: 25) {
                    Button("Confirm", action: {
                        uploadImageTask.run {
                            try await updateImageAction(image)
                            newImageCandidate = nil
                        }
                    })
                    Button("Cancel", role: .destructive, action: {
                        newImageCandidate = nil
                    })
                }
                .disabled(uploadImageTask.isInProgress)
            } else {
                AsyncImage(url: URL(string: user.imageURL), content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                }, placeholder: {
                    VStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 50)
                        Text("Image downloading...")
                            .font(.caption)
                    }
                }
                )
                Button("Change Photo", action: {
                    showChooseImageSource = true
                })
            }
            Spacer()
            Text("User Name:")
            Text(user.name)
                .font(.title2)
                .bold()
            Spacer()
            Button(action: signOut) {
                Text("Sign Out")
                    .foregroundColor(Color.white)
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .disabled(signOutTask.isInProgress)
            Spacer()
        }
        .alert("Cannot Update Profile Photo", isPresented: $uploadImageTask.isError, presenting: uploadImageTask.error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
        .alert("Cannot Sign Out", isPresented: $signOutTask.isError, presenting: signOutTask.error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
        .confirmationDialog("Change Profile Photo", isPresented: $showChooseImageSource, titleVisibility: .visible) {
            Button("Choose from Library", action: {
                imageSourceType = .photoLibrary
            })
            Button("Take Photo", action: {
                imageSourceType = .camera
            })
        }
        .sheet(item: $imageSourceType) {
            ImagePickerView(sourceType: $0, selection: $newImageCandidate)
        }
    }
    
    private func signOut() {
        signOutTask.run(action: signOutAction)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .testUser, updateImageAction: { _ in }, signOutAction: {})
    }
}
