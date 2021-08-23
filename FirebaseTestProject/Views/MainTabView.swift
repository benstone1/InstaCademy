//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var postData: PostData = PostData()
    
    var body: some View {
        TabView {
            PostsList(viewStyle: .all)
                .tabItem {
                    Label("Posts", systemImage: "list.dash")
                }
            PostsList(viewStyle: .favorites)
                .tabItem {
                    Label("Favorites",
                    systemImage: "heart.fill")
                }
        }
        .environmentObject(postData)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
