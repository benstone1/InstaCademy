//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    @Binding var route: PostsList.Route?
    let favoriteAction: Action
    let deleteAction: Action?
    
    typealias Action = () async throws -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.author.name)
                    .font(.caption)
            }
            if let imageURL = post.imageURL {
                PostImage(url: imageURL)
            }
            Text(post.text)
            HStack(alignment: .center, spacing: 10) {
                Text(post.timestamp.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button {
                    route = .comments(post)
                } label: {
                    Label("Comments", systemImage: "text.bubble")
                }
                FavoriteButton(isFavorite: post.isFavorite, action: favoriteAction)
                if let deleteAction = deleteAction {
                    DeleteButton(action: deleteAction)
                }
            }
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
        }
    }
}

private extension PostRow {
    struct PostImage: View {
        let url: URL
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 300, height: 200)
            } placeholder: {
                VStack {
                    ProgressView()
                    Text("Loading Image")
                        .font(.caption)
                }
                .frame(width: 300, height: 200)
            }
            .padding(.horizontal)
        }
    }
    
    struct FavoriteButton: View {
        let isFavorite: Bool
        let action: Action
        
        @StateObject private var task = TaskViewModel()
        
        var body: some View {
            Button {
                task.run(action: action)
            } label: {
                if isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .disabled(task.isInProgress)
        }
    }
    
    struct DeleteButton: View {
        let action: Action
        
        @StateObject var task = DeleteTaskViewModel()
        
        var body: some View {
            Button(role: .destructive) {
                task.request(with: action)
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .disabled(task.isInProgress)
            .confirmationDialog("Are you sure you want to delete this post?", isPresented: $task.isPending, titleVisibility: .visible, presenting: task.confirmAction) {
                Button("Delete", role: .destructive, action: $0)
            }
            .alert("Cannot Delete Post", isPresented: $task.isError, presenting: task.error) { error in
                Text(error.localizedDescription)
            }
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(post: .testPost, route: .constant(nil), favoriteAction: {}, deleteAction: {})
        }
    }
}
