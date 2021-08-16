//
//  SignInViewModel.swift
//  SignInViewModel
//
//  Created by Tim Miller on 8/12/21.
//


import FirebaseAuth

class SignInViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let userDefault = UserDefaults.standard
    
    @Published var signedIn = UserDefaults.standard.bool(forKey: "userSignedIn")
    
    func getUser() -> String {
        guard let user = auth.currentUser?.email else {
            return "No User"
        }
        return user
    }
    
    func signIn(email: String, password: String){
        
        auth.signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard result != nil, error == nil else { return }
            
            self!.userDefault.set(true, forKey: "userSignedIn")
            self!.userDefault.synchronize()
            
            DispatchQueue.main.async {
                self!.signedIn = true
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.userDefault.set(false, forKey: "userSignedIn")
            self.userDefault.synchronize()
            DispatchQueue.main.async {
                self.signedIn = false
            }
        } catch {
            print(error)
        }
    }
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard result != nil, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
}
