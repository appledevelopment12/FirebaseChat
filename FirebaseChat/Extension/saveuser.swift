import FirebaseFirestore

func saveGoogleUserInfo(uid: String, name: String, email: String, image: String) {
    let db = Firestore.firestore()
    
    let userData: [String: Any] = [
        "uid": uid,
        "name": name,
        "email": email,
        "profileImage": image,
        "createdAt": Timestamp()
    ]

    db.collection("users").document(uid).setData(userData, merge: true) { error in
        if let error = error {
            print("Error saving user: \(error)")
        } else {
            print("User saved successfully → uid:", uid)
        }
    }
}
