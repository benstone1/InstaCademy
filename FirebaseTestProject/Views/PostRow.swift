//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    let deleteAction: DeleteAction?
    
    typealias DeleteAction = () async throws -> Void
    
    @StateObject private var deleteTask = DeleteTaskViewModel()
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title)
                .padding(.bottom, 8)
            Text(post.text)
                .font(.body)
                .padding(.bottom, 8)
            Text(post.author.name)
                .padding(.bottom, 8)
                .padding()
            HStack {
                Text(post.author.name)
                if let deleteAction = deleteAction {
                    Spacer()
                    deleteButton(with: deleteAction)
                }
            }
            .padding(.bottom, 8)
        }
        .alert("Are you sure you want to delete this comment?", isPresented: $deleteTask.isPending, presenting: deleteTask.confirmAction) {
            Button("Delete", role: .destructive, action: $0)
        }
        .alert("Cannot Delete Comment", isPresented: $deleteTask.isError, presenting: deleteTask.error) { error in
            Text(error.localizedDescription)
        }
    }
    
    private func deleteButton(with deleteAction: @escaping DeleteAction) -> some View {
        Button {
            deleteTask.request(with: deleteAction)
        } label: {
            Label("Delete", systemImage: "trash")
                .foregroundColor(Color.red)
                .labelStyle(IconOnlyLabelStyle())
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRow(post: Post.testPost, deleteAction: {})
    }
}
