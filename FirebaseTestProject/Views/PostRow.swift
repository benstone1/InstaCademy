//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    @Binding  var post: Post
    @State var isPresenting: Bool = false
    @State private var showAlert: Bool = false
    let deletePostAction:((Post) -> Void)
    
    init(post: Binding<Post>, deletePostAction: @escaping (Post) -> Void) {
        self._post = post
        self.deletePostAction = deletePostAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(post.title)
                    .font(.largeTitle)
                    .padding(.leading)
                Spacer()
                let userid = UserDefaults.standard.value(forKey: "userid") != nil ? UUID(uuidString: UserDefaults.standard.value(forKey: "userid") as! String) : UUID(uuidString: "00854E9E-8468-421D-8AA2-605D8E6C61D9")
                if userid == post.authorid {
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(IconOnlyLabelStyle())
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Do you want to delete this post?"),
                      primaryButton: .cancel(),
                      secondaryButton: .destructive(Text("Delete")) {
                    deletePostAction(post)
                })
            }
            HStack {
                Text(post.author)
                    .padding()
                    .foregroundColor(Color(uiColor: UIColor.systemBlue))
                    .onTapGesture {
                        isPresenting = true
                    }.sheet(isPresented: $isPresenting, onDismiss: {
                        isPresenting = false
                    }) {
                        PostsList(viewStyle: .singleAuthor(post.author))
                    }
                Spacer()
                // DateFormatter inside /Models/Post.swift
                Text(DateFormatter.postFormat(date: post.timestamp))
            }
            .padding([.leading, .trailing], 20)
            Divider()
            Text(post.text)
                .font(.body)
                .padding([.bottom, .top])
                .padding(.leading, 30)
                // Accomplishes Auto-Height for Multi-Text
                // It expands the view to a fixed size Vertically, but maintains the stature of
                // the horizontal component
                .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color.orange.opacity(0.5))
        .cornerRadius(10)
    }
}

struct PostRow_Previews: PreviewProvider {
    @State static var post: Post = Post(title: "", text: "", author: "")
    static var previews: some View {
        PostRow(post: $post, deletePostAction: { post in
            print(post)
        })
    }
}
