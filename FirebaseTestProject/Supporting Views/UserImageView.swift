//
//  UserImageView.swift
//  UserImageView
//
//  Created by John Royal on 9/11/21.
//

import SwiftUI

struct UserImageView: View {
    let url: URL?
    var transaction = Transaction(animation: .none)
    
    var body: some View {
        GeometryReader { proxy in
            AsyncImage(url: url, transaction: transaction) { phase in
                Group {
                    switch phase {
                    case .failure(_):
                        Image("ProfileImagePlaceholder")
                            .resizable()
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
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

struct UserImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserImageView(url: User.testUser.imageURL)
            UserImageView(url: nil)
        }
        .frame(width: 300, height: 300)
        .padding()
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
