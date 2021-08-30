//
//  ProfileView.swift
//  ProfileView
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

struct ProfileView: View {
    @State var user: User
    let signOutAction: () async throws -> Void
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isSelectingImage = false
    @State private var changingProfilePhoto = false
    @State private var image: UIImage?
    
    @StateObject private var signOutTask = TaskViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                HStack(alignment: .center, spacing: 25) {
                    Button {
                        signOutTask.run {
                            user.imageURL = await UserService.uploadPhoto(user, image: image)
//                            user.imageURL = await UserService.uploadPhoto(user, image: image)
//                            UserService.updateURL(user, imageURL: user.imageURL)
                            self.image = nil
                        }
                    } label: {
                        Text("Confirm")
                    }
                    Button {self.image = nil} label: {
                        Text("Cancel")
                            .foregroundColor(Color.red)
                    }
                }
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
                Button { changingProfilePhoto.toggle()} label: {
                    Text("Change Photo")
                }
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
        .alert("Cannot Sign Out", isPresented: $signOutTask.isError, presenting: signOutTask.error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
        .alert(isPresented: $changingProfilePhoto) {
            Alert(title: Text("Changing Profile Picture"), message: Text("Select where you would like your image to come from:"), primaryButton: .default(Text("Camera")) {
                sourceType = .camera
                isSelectingImage.toggle()
            }, secondaryButton: .default(Text("Library")) {
                sourceType = .photoLibrary
                isSelectingImage.toggle()
            })
        }
        .sheet(isPresented: $isSelectingImage) {
            ImagePickerView(sourceType: sourceType, selection: $image)
        }
    }
    
    private func signOut() {
        signOutTask.run(action: signOutAction)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .testUser, signOutAction: {})
    }
}
