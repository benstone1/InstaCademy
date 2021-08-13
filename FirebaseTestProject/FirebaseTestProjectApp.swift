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
      let signInViewModel = SignInViewModel()
      WindowGroup {
        MainTabView()
          .environmentObject(signInViewModel)
      }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()
    return true

  }

}
