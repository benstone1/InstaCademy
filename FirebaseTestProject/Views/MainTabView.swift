//
//  MainTabView.swift
//  MainTabView
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var signInViewModel: SignInViewModel
    
    var body: some View {
        if signInViewModel.signedIn {
            TabView{
                PostsList()
                    .tabItem {
                        Label("Posts", systemImage: "list.dash")
                    }
                NewPostForm()
                    .tabItem {
                        Label("New Post", systemImage: "plus.circle")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "gear")
                    }
            }
            .onAppear {
                signInViewModel.signedIn = signInViewModel.isSignedIn
            }
        } else {
            SignInView()
        }

    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(SignInViewModel())
    }
}
