//
//  SignupVC.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestoreInternal


class SignupVC: UIViewController {
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
    }
    
    @IBAction func googleSignBtn(_ sender: UIButton){
                if let token = UserDefaults.standard.string(forKey: "googleIDToken"), !token.isEmpty {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserListVC") as! UserListVC
                    self.navigationController?.pushViewController(vc, animated: true)

        
                   } else {
                      SignupCall()
         }
    }
    func SignupCall() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error)")
                return
            }
            
            guard let googleUser = result else { return }
            
            // Google Profile Details
            let email = googleUser.user.profile?.email ?? ""
            let firstName = googleUser.user.profile?.givenName ?? ""
            let lastName = googleUser.user.profile?.familyName ?? ""
            let profileURL = googleUser.user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
            let uid = googleUser.user.userID ?? ""
            
            // Firebase Credentials
            guard let idToken = googleUser.user.idToken else { return }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: googleUser.user.accessToken.tokenString
            )
            
            // Firebase Sign-In
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error)")
                    return
                }
                
                print("Firebase login successful")
                
                // Save Google User to Firestore
                saveGoogleUserInfo(
                    uid: uid,
                    name: "\(firstName) \(lastName)",
                    email: email,
                    image: profileURL
                )
                
                // Save local data if needed
                UserDefaults.standard.set(uid, forKey: "userId")
                UserDefaults.standard.set(profileURL, forKey: "profileURL")
                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "profileName")
                
                // Navigate to UserListVC
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "UserListVC") as? UIViewController {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
}
