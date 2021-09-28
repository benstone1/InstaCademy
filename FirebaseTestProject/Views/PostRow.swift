//
//  PostRow.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

// MARK: - PostRow

struct PostRow: View {
    @ObservedObject var viewModel: PostRowViewModel
    
    private typealias Route = PostRowViewModel.Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PostAuthorView(author: viewModel.author, action: {
                viewModel.route = .author
            })
            if let imageURL = viewModel.imageURL {
                PostImageView(url: imageURL)
            }
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(viewModel.content)
            PostFooterView(viewModel: viewModel)
        }
        .foregroundColor(.gray9)
        .padding()
        .alert("Something went wrong.", isPresented: $viewModel.error.exists, presenting: viewModel.error, actions: { _ in }) {
            Text($0.localizedDescription)
        }
        .background {
            NavigationLink(tag: Route.author, selection: $viewModel.route) {
                PostsList(viewModel: viewModel.makePostViewModel())
            }
            NavigationLink(tag: Route.comments, selection: $viewModel.route) {
                CommentsList(viewModel: viewModel.makeCommentViewModel())
            }
        }
    }
}

private extension NavigationLink where Label == EmptyView {
    init<Tag: Hashable>(tag: Tag, selection: Binding<Tag?>, @ViewBuilder destination: @escaping () -> Destination) {
        self.init(tag: tag, selection: selection, destination: destination, label: EmptyView.init)
    }
}

// MARK: - PostAuthorView

private extension PostRow {
    struct PostAuthorView: View {
        let author: User
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    UserImageView(author)
                        .frame(width: 40, height: 40)
                        .accentColor(.beige)
                        .foregroundColor(.gray9)
                    Text(author.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray9)
                }
                .accessibilityElement(children: .combine)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - PostImageView

private extension PostRow {
    struct PostImageView: View {
        let url: URL
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Color.clear
                    .frame(height: 200)
            }
        }
    }
}

// MARK: - PostFooterView

private extension PostRow {
    struct PostFooterView: View {
        @ObservedObject var viewModel: PostRowViewModel
        
        // These shouldn’t be necessary, but they’re here as a workaround for a SwiftUI preview bug.
        private typealias FavoriteButton = PostRow.FavoriteButton
        private typealias DeleteButton = PostRow.DeleteButton
        
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                FavoriteButton(isFavorite: viewModel.isFavorite) {
                    viewModel.toggleFavorite()
                }
                Button {
                    viewModel.route = .comments
                } label: {
                    Label("Comments", systemImage: "text.bubble")
                }
                Spacer()
                if viewModel.canDelete() {
                    DeleteButton {
                        viewModel.delete()
                    }
                }
                Text(viewModel.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.gray4)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
        }
    }
    
    struct FavoriteButton: View {
        let isFavorite: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                if isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                        .foregroundColor(.appPink)
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .animation(.default, value: isFavorite)
        }
    }
    
    struct DeleteButton: View {
        let action: () -> Void
        
        @State private var isShowingConfirmation = false
        
        var body: some View {
            Button(role: .destructive) {
                isShowingConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .alert("Are you sure you want to delete this post?", isPresented: $isShowingConfirmation) {
                Button("Delete", role: .destructive, action: action)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Post.testPosts) {
            PostRow(viewModel: PostRowViewModel(post: $0, postService: PostServiceStub()))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
