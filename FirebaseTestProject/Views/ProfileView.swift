//
//  ProfileView.swift
//  FirebaseTestProject
//
//  Created by Tim Miller on 8/12/21.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    let user: User
    
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                UserImageView(user, transaction: Transaction(animation: .default))
                    .frame(width: 200, height: 200)
                    .padding()
                UpdateImageButton(updateAction: {
                    viewModel.updateProfileImage($0)
                }, removeAction: {
                    viewModel.removeProfileImage()
                })
                Spacer()
                Text("Signed in as:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(user.name)
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .disabled(viewModel.isLoading)
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                SignOutButton(action: {
                    viewModel.signOut()
                })
            }
        }
        .alert("Error", isPresented: $viewModel.error.exists, presenting: viewModel.error, actions: { _ in }) { error in
            Text(error.localizedDescription)
        }
    }
}

// MARK: - SignOutButton

private extension ProfileView {
    struct SignOutButton: View {
        let action: () -> Void
        
        @State private var isShowingConfirmation = false
        
        var body: some View {
            Button("Sign Out", action: {
                isShowingConfirmation = true
            })
                .confirmationDialog("Sign Out", isPresented: $isShowingConfirmation) {
                    Button("Sign Out", role: .destructive, action: action)
                }
        }
    }
}

// MARK: - UpdateImageButton

private extension ProfileView {
    struct UpdateImageButton: View {
        let updateAction: (UIImage) -> Void
        let removeAction: () -> Void
        
        @State private var newImageCandidate: UIImage?
        @State private var showChooseImageSource = false
        @State private var imageSourceType: ImagePickerView.SourceType?
        
        @Environment(\.isEnabled) private var isEnabled
        
        var body: some View {
            Button {
                showChooseImageSource = true
            } label: {
                if isEnabled {
                    Label("Change Photo", systemImage: "plus")
                } else {
                    ProgressView()
                }
            }
            .confirmationDialog("Choose Profile Photo", isPresented: $showChooseImageSource) {
                Button("Choose from Library", action: {
                    imageSourceType = .photoLibrary
                })
                Button("Take Photo", action: {
                    imageSourceType = .camera
                })
                Button("Remove Photo", role: .destructive, action: {
                    removeAction()
                })
            }
            .sheet(item: $imageSourceType, onDismiss: {
                guard let image = newImageCandidate else { return }
                updateAction(image)
                newImageCandidate = nil
            }) {
                ImagePickerView(sourceType: $0, selection: $newImageCandidate)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePreview(user: User.testUser(imageURL: nil))
        ProfilePreview(user: User.testUser())
    }
    
    @MainActor
    private struct ProfilePreview: View {
        let user: User
        
        var body: some View {
            ProfileView(user: user)
                .environmentObject(AuthViewModel(authService: AuthServiceStub(user: user)))
        }
    }
}
#endif
