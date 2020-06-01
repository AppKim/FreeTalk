//
//  GroupChatRoomViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/25.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class GroupChatRoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldMessage: UITextView!
    
    @IBOutlet weak var chatTableView: UITableView!
    var destinationRoom: String?
    var uid: String?
    var comments : [ChatModel.Comment] = []
    var users : [String:AnyObject]?

    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        chatTableView.separatorStyle = .none

        databaseRef.child("users").observeSingleEvent(of: .value) { (datasnapshot) in
            self.users = datasnapshot.value as! [String:AnyObject]
            
        }
        
        chatTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        chatTableView.register(UINib(nibName: "DestinationMessageCell", bundle: nil), forCellReuseIdentifier: "DestinationMessageCell")
        
        getMessageList()
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func sendMessage(){
        
        let value :Dictionary<String,Any>  = [
            
            "uid":uid!,
            "message":textFieldMessage.text!,
            "timestamp":ServerValue.timestamp()
        
        ]
        
        databaseRef.child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) { (err, ref) in
            
            self.textFieldMessage.text = ""
            
        }
        
        
    }
    
    func getMessageList(){
        
        databaseRef.child("chatrooms").child(destinationRoom!).child("comments").observe(.value) { (datasnapshot) in
            if datasnapshot.hasChildren(){
                
                self.comments.removeAll()
                
                for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                    
                    /*print(item)
                    print(item.value)
                    print(item.key)
                    */
                    
                    let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                    //print(comment?.uid as! String)
                    self.comments.append(comment!)
                    self.chatTableView.reloadData()
                    
                }
                //print("===========")
                
            }
        }

        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments[indexPath.row].uid == uid {
            
            let myCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            myCell.myMessage.text = comments[indexPath.row].message
            if let time = self.comments[indexPath.row].timestamp {
                myCell.timestamp.text = time.toDayTime
            }
            
            return myCell
            
        }else{
            
            let destinationUsers = users![comments[indexPath.row].uid!]
            
            let destinationCell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            
            destinationCell.destinationName.text = destinationUsers!["userName"] as! String
            destinationCell.destinationMessage.text = comments[indexPath.row].message
            
            
            let imageUrl = destinationUsers!["profileImageUrl"] as! String
            
            let url = URL(string: (imageUrl))
            
            destinationCell.destinationImage.layer.cornerRadius = destinationCell.destinationImage.frame.size.height / 2
            destinationCell.destinationImage.clipsToBounds = true
            destinationCell.destinationImage.kf.setImage(with: url)
            
            if let time  = self.comments[indexPath.row].timestamp {
                destinationCell.timestamp.text = time.toDayTime
            }
            
            return destinationCell
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
