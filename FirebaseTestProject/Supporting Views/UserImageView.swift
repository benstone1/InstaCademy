//
//  UserImageView.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/11/21.
//

import SwiftUI

// MARK: - UserImageView

struct UserImageView: View {
    let user: User
    let transaction: Transaction
    
    init(_ user: User, transaction: Transaction = Transaction(animation: .none)) {
        self.user = user
        self.transaction = transaction
    }
    
    var body: some View {
        GeometryReader { proxy in
            AsyncImage(url: user.imageURL, transaction: transaction) { phase in
                Group {
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_), .empty where user.imageURL == nil:
                        ZStack {
                            Color.accentColor
                            Text(user.initials)
                                .font(Font.system(size: proxy.size.width * 0.4))
                        }
                    default:
                        Color.clear
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipShape(Circle())
            }
        }
    }
}

private extension User {
    var initials: String {
        name
            .split(separator: " ")
            .compactMap {
                guard let character = $0.first else { return nil }
                return String(character)
            }
            .joined()
    }
}

// MARK: - Previews

#if DEBUG
struct UserImageView_Previews: PreviewProvider {
    static var previews: some View {
        UserImagePreview(user: User.testUser(imageURL: nil))
        UserImagePreview(user: User.testUser())
    }
    
    private struct UserImagePreview: View {
        let user: User
        
        var body: some View {
            UserImageView(user)
                .accentColor(.beige)
                .foregroundColor(.gray9)
                .frame(width: 300, height: 300)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
