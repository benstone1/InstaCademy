//
//  PostView.swift
//  PostView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct PostRow: View {
    let post: Post
    
    
   var body: some View {
         VStack {
             Text(post.title)
                 .font(.title)
                 .padding(.bottom, 8)
             Text(post.text)
                 .font(.body)
                 .padding(.bottom, 8)
             Text(post.author)
                 .padding(.bottom, 8)
         }
   }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
         PostRow(post: Post.testPost)
    }
}
