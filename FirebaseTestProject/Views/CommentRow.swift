//
//  CommentRow.swift
//  CommentRow
//
//  Created by John Royal on 8/21/21.
//

import SwiftUI

// MARK: - CommentRow

struct CommentRow: View {
    let comment: Comment
    let deleteAction: DeleteAction?
    
    typealias DeleteAction = () async throws -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(comment.author.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(comment.timestamp.formatted())
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text(comment.content)
                .font(.headline)
                .fontWeight(.regular)
        }
        .padding(5)
        .deletable(action: deleteAction)
    }
}

// MARK: - DeleteViewModifier

private extension View {
    func deletable(action: CommentRow.DeleteAction?) -> some View {
        modifier(CommentRow.DeleteViewModifier(action: action))
    }
}

private extension CommentRow {
    struct DeleteViewModifier: ViewModifier {
        let action: DeleteAction?
        
        @StateObject private var task = DeleteTaskViewModel()
        
        func body(content: Content) -> some View {
            content
                .swipeActions {
                    if let action = action {
                        Button(role: .destructive) {
                            task.request(action)
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .confirmationDialog("Are you sure you want to delete this comment?", isPresented: $task.isPending, titleVisibility: .visible, presenting: task.confirmAction) {
                    Button("Delete", role: .destructive, action: $0)
                }
                .alert("Cannot Delete Comment", isPresented: $task.isError, presenting: task.error) { error in
                    Text(error.localizedDescription)
                }
        }
    }
}

// MARK: - Preview

struct CommentRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CommentRow(comment: .testComment, deleteAction: {})
            CommentRow(comment: .testComment, deleteAction: nil)
        }
    }
}
