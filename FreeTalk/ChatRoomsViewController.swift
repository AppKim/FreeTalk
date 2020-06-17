//
//  ChatRoomsViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/12.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationImage: UIImageView!
    
    @IBOutlet weak var timestamp: UILabel!
}

class ChatRoomsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var uid : String!
    var chatRooms :[ChatModel] = []
    var destinationUsers: [String] = []

    var keys: [String] = []
    
    let databaseRef = Database.database().reference()
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatRoomsList()
        chatTableView.separatorStyle = .none
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func getChatRoomsList(){
        
        databaseRef.child("chatrooms").queryOrdered(byChild: "users"+uid).observeSingleEvent(of: .value) { (datasnapshot) in
            self.chatRooms.removeAll()
            self.destinationUsers.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatroomdic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.keys.append(item.key)
                    self.chatRooms.append(chatModel!)
                    
                }
            }
            self.chatTableView.reloadData()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.chatRooms[indexPath.row].users.count > 2 {
            let s = UIStoryboard(name: "GroupChatRoomViewController", bundle: nil)
            let chatVC = s.instantiateViewController(withIdentifier: "GroupChatRoomViewController") as! GroupChatRoomViewController
            chatVC.destinationRoom = self.keys[indexPath.row]
            self.navigationController?.pushViewController(chatVC, animated: true)

            
        }else{
            let destinationUid = destinationUsers[indexPath.row]
            let s = UIStoryboard(name: "ChatViewController", bundle: nil)
            let chatVC = s.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVC.destinationUid = destinationUid
            self.navigationController?.pushViewController(chatVC, animated: true)

            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoomCell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        var destinationUid :String?
        for item in chatRooms[indexPath.row].users {
            if(item.key != self.uid){
                destinationUid = item.key
                self.destinationUsers.append(destinationUid!)
            }
        }
        
        
        databaseRef.child("users").child(destinationUid!).observeSingleEvent(of: .value) { (datasnapshot) in
            
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:Any])
            chatRoomCell.destinationName.text = userModel.userName
            
            let url = URL(string: userModel.profileImageUrl!)
            
            chatRoomCell.destinationImage.layer.cornerRadius = chatRoomCell.destinationImage.frame.width/2
            chatRoomCell.destinationImage.layer.masksToBounds = true
            chatRoomCell.destinationImage.kf.setImage(with: url)

        }
        
        let lastMessageKey = self.chatRooms[indexPath.row].comments.keys.sorted(){$0>$1}
        
        if chatRooms[indexPath.row].comments.count > 0 {
            chatRoomCell.lastMessage.text = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.message
            chatRoomCell.timestamp.text = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp?.toDayTime
        }else {
            chatRoomCell.lastMessage.text = ""
            chatRoomCell.timestamp.text = ""
        }
        

        return chatRoomCell
    }
    
    // MARK: - Navigation キーボード実装
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
