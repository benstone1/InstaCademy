//
//  FirebaseTestProjectApp.swift
//  FirebaseTestProject
//
//  Created by Ben Stone on 8/9/21.
//

import SwiftUI
import Firebase

@main
struct FirebaseTestProjectApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
      let authViewModel = AuthViewModel()
      WindowGroup {
        MainTabView()
          .environmentObject(authViewModel)
      }
    }
}
