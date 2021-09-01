//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    let favoriteAction: Action
    let deleteAction: Action?
    
    typealias Action = () async throws -> Void
    
    @StateObject private var favoriteTask = TaskViewModel()
    @StateObject private var deleteTask = DeleteTaskViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            if !post.imageURL.isEmpty {
                image
            }
            Text(post.text)
            footer
        }
        .confirmationDialog("Are you sure you want to delete this post?", isPresented: $deleteTask.isPending, titleVisibility: .visible, presenting: deleteTask.confirmAction) {
            Button("Delete", role: .destructive, action: $0)
        }
        .alert("Cannot Delete Post", isPresented: $deleteTask.isError, presenting: deleteTask.error) { error in
            Text(error.localizedDescription)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.headline)
            Text(post.author.name)
                .font(.caption)
        }
    }
    
    private var image: some View {
        AsyncImage(url: URL(string: post.imageURL)) { image in
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
    
    private var footer: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(post.timestamp.formatted())
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Button {
                favoriteTask.run(action: favoriteAction)
            } label: {
                if post.isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .foregroundColor(.blue)
            if let deleteAction = deleteAction {
                Button(role: .destructive) {
                    deleteTask.request(with: deleteAction)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .labelStyle(IconOnlyLabelStyle())
        .buttonStyle(PlainButtonStyle())
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(post: .testPost, favoriteAction: {}, deleteAction: {})
        }
    }
}
