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
    
    @StateObject private var task = TaskViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            UserImageView(url: user.imageURL, transaction: Transaction(animation: .default))
                .frame(width: 300, height: 300)
                .overlay(Circle().stroke(Color(uiColor: .systemGray5), lineWidth: 2))
            Button("Change Photo", action: {
                showChooseImageSource = true
            })
                .disabled(task.isInProgress)
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
            .disabled(task.isInProgress)
            Spacer()
        }
        .alert(isPresented: $task.isError) {
            Alert(
                title: Text("Error"),
                message: Text(task.error?.localizedDescription ?? "Sorry, something went wrong."),
                dismissButton: nil
            )
        }
        .confirmationDialog("Choose Profile Photo", isPresented: $showChooseImageSource, titleVisibility: .visible) {
            Button("Choose from Library", action: {
                imageSourceType = .photoLibrary
            })
            Button("Take Photo", action: {
                imageSourceType = .camera
            })
        }
        .sheet(item: $imageSourceType, onDismiss: {
            guard let image = newImageCandidate else { return }
            task.perform {
                try await updateImageAction(image)
                newImageCandidate = nil
            }
        }) {
            ImagePickerView(sourceType: $0, selection: $newImageCandidate)
        }
    }
    
    private func signOut() {
        task.perform(signOutAction)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .testUser, updateImageAction: { _ in }, signOutAction: {})
    }
}
