//
//  ContentView.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostsList: View {
    @EnvironmentObject private var postData: PostData
    let viewStyle: ViewStyle
    
    var body: some View {
        NavigationView {
            VStack {
                
                let prefSize = 0.9

                ScrollView(.vertical) {
                    GeometryReader { g in
                        VStack {
                            ForEach(posts, id: \.id) { post in
                                PostRow(post: binding(for: post), deletePostAction: { post in
                                    postData.remove(post: post)
                                }, isFavoriteAction: { post in
                                    if post.isFavorite {
                                        postData.favorites.append(post)
                                    }
                                    else {
                                        guard let index = postData.favorites.firstIndex(where: { $0.id == post.id }) else { return }
                                        postData.favorites.remove(at: index)
                                    }
                                })
                            }
                        }
                        .frame(width: g.size.width*prefSize)
                    }  
                }
                .alignmentGuide(HorizontalAlignment.center, computeValue: { d in
                    let scrollViewWidth = d.width*2
                    let scrollViewWidthPrefSize = scrollViewWidth*prefSize
                    let midwayPoint = (scrollViewWidth - scrollViewWidthPrefSize) / 2
                    return d[HorizontalAlignment.center] - midwayPoint
                })
                .navigationTitle("Posts")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Create Post") {
                            isPresenting = true
                        }
                    }
                })
            }
            .sheet(isPresented: $isPresenting, content: {
                NavigationView {
                    NewPostForm()
                        .toolbar(content: {
                            Button("Dismiss") {
                                isPresenting = false
                            }
                        })
                }
            })
        }
    }
}


extension PostsList {
    enum ViewStyle {
        case all
        case favorites
        case singleAuthor(String)
    }
    
    func binding(for post: Post) -> Binding<Post> {
        guard let index = postData.index(of: post) else {
            fatalError("Post not found")
        }
        return $postData.posts[index]
    }
    
    private var posts: [Post] {
        switch viewStyle {
        case .all:
            return postData.posts
        case .favorites:
            return postData.favorites
        case let .singleAuthor(author):
            return postData.posts.filter({ $0.author == author })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static private var postData: PostData = PostData()
    static var previews: some View {
        PostsList(viewStyle: .all)
    }
}

