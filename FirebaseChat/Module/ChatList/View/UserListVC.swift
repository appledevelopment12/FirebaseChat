//
//  UserListVC.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.
//

import UIKit
import SDWebImage
import FirebaseFirestore


class UserListVC: UIViewController {

    @IBOutlet weak var userListTable: UITableView!
    @IBOutlet weak var profilenamelbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    
    var userList: [AppUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUserList()
        self.navigationController?.navigationBar.isHidden = true
        profilenamelbl.text = UserDefaults.standard.string(forKey: "profileName") ?? "No Name"
        
        profileImg.sd_setImage(with: URL(string: UserDefaults.standard.string(forKey: "profileURL") ?? ""),placeholderImage: UIImage(named:"placeholder"))
    }
    func getUserList() {
        let db = Firestore.firestore()
        
        let currentUid = UserDefaults.standard.string(forKey: "userId") ?? ""   // 👈 Current User UID
        
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users:", error.localizedDescription)
                return
            }
            
            self.userList = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                
                let uid = data["uid"] as? String ?? ""
                
                // 👇 CURRENT USER hide karega (IMPORTANT)
                if uid == currentUid {
                    return nil
                }
                
                return AppUser(
                    uid: uid,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    image: data["profileImage"] as? String ?? ""
                )
            } ?? []
            
            self.userListTable.reloadData()
        }
    }



    func setupUI(){
        userListTable.delegate = self
        userListTable.dataSource = self
        userListTable.separatorStyle = .none
        userListTable.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        

    }
}
extension UserListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        let user = userList[indexPath.row]
        
        cell.userName.text = user.name
        cell.userImg.sd_setImage(with: URL(string: user.image),
                                 placeholderImage: UIImage(named: "placeholder"))
        cell.selectionStyle = .none
        return cell
       
    }
    func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {

            let selectedUser = userList[indexPath.row]

            let currentUser = UserDefaults.standard.string(forKey: "userId") ?? ""
            let otherUser = selectedUser.uid

            // Create chatroom ID (always same order)
            let chatRoomId = currentUser < otherUser
                ? "\(currentUser)_\(otherUser)"
                : "\(otherUser)_\(currentUser)"

            // push to chat screen
            let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ChatScreen") as! ChatScreen

            // Create ViewModel
            vc.viewModel = ChatViewModel(
                chatRoomId: chatRoomId,
                currentUserId: currentUser,
                otherUserId: otherUser
            )

            vc.username = selectedUser.name
            navigationController?.pushViewController(vc, animated: true)
        }
}
