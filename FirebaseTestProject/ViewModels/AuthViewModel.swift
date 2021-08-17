//
//  AuthViewModel.swift
//  AuthViewModel
//
//  Created by Tim Miller on 8/12/21.
//


import FirebaseAuth
import SwiftUI

@MainActor class AuthViewModel: ObservableObject {
  
  private let auth = Auth.auth()
  
  @AppStorage("userSignedIn") var userSignedIn: Bool = false
  
  func getUser() -> String {
    guard let user = auth.currentUser?.email else {
      return "No User"
    }
    return user
  }
  
  func signIn(email: String, password: String) async {
    do {
      try await auth.signIn(withEmail: email, password: password)
      UserDefaults.standard.set(true, forKey: "userSignedIn")
      userSignedIn = true
    } catch {
      print(error)
    }
  }
  
  func signOut() async {
    do {
      try auth.signOut()
      UserDefaults.standard.set(false, forKey: "userSignedIn")
      userSignedIn = false
    } catch {
      print(error)
    }
  }
  
  func signUp(email: String, password: String) async {
    do {
      try await auth.createUser(withEmail: email, password: password)
      UserDefaults.standard.set(true, forKey: "userSignedIn")
      userSignedIn = true
    } catch {
      print(error)
    }
  }
}
