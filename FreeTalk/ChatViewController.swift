//
//  ChatViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/06.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase



class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputMessageView: NSLayoutConstraint!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var inputMessageHeight: NSLayoutConstraint!
    
    var uid: String?
    var chatRoomUid: String?
    
    var comments : [ChatModel.Comment] = []
    var userModel : UserModel?
    
    // チャットする相手のUid
    public var destinationUid: String?
    
    let databasesRef = Database.database().reference().child("chatrooms")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        chatTableView.separatorStyle = .none
        
        chatTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        chatTableView.register(UINib(nibName: "DestinationMessageCell", bundle: nil), forCellReuseIdentifier: "DestinationMessageCell")
        
        uid = Auth.auth().currentUser?.uid
        
        checkChatRoom()
        
        //sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    // 종료
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if comments[indexPath.row].uid == uid {
            let myCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell",for: indexPath) as! MyMessageCell
            myCell.myMessage.text = self.comments[indexPath.row].message
            myCell.selectionStyle = .none
            return myCell
        }else{
            let destinationCell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell",for: indexPath) as! DestinationMessageCell
            destinationCell.destinationMessage.text = self.comments[indexPath.row].message
            destinationCell.destinationName.text = self.userModel?.userName
            destinationCell.selectionStyle = .none
            
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                DispatchQueue.main.async {
                    
                    destinationCell.destinationImage.image = UIImage(data: data!)
                    destinationCell.destinationImage.layer.cornerRadius = destinationCell.destinationImage.frame.size.height / 2
                    destinationCell.destinationImage.clipsToBounds = true
                    
                }
            }.resume()
            
            return destinationCell
        }
    }
    
    
    @objc func createRoom(){
        let createRoomInfo : Dictionary<String,Any> = [
            "users": [
                uid:true,
                destinationUid:true
            ]
        ]
        /*
         let chatContent : Dictionary<String,Any> = [
         "uid":uid!,
         "message":message.text!
         ]*/
        //if chatRoomUid == nil {
            
            //self.sendButton.isEnabled = false
            databasesRef.childByAutoId().setValue(createRoomInfo) { (error, ref) in
                if error == nil {
                    //self.checkChatRoom()
                }
            }
        //}
        /*else{
         databasesRef.child(chatRoomUid!).child("comments").childByAutoId().setValue(chatContent) { (error, ref) in
         if error == nil {
         
         }
         }
         }
         */
    }
    
    @objc func sendMessage(){
        let chatContent : Dictionary<String,Any> = [
            "uid":uid!,
            "message":message.text!
        ]
        databasesRef.child(chatRoomUid!).child("comments").childByAutoId().setValue(chatContent) { (error, ref) in
            if error == nil {
                
            }
        }
    }
    
    
    func checkChatRoom(){
        databasesRef.queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value,with:  { (datasnapshot) in
            if datasnapshot.value is NSNull{
                self.createRoom()
            }else {
                for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let chatRoomdic = item.value as? [String:AnyObject]{
                        
                        let chatModel = ChatModel(JSON: chatRoomdic)
                        print(chatModel?.users)
                        
                        if chatModel?.users[self.destinationUid!] == true {
                            
                            self.chatRoomUid  = item.key
                            //self.sendButton.isEnabled = true
                            self.getDestinationInfo()
                            break
                        }
                    }
                }
                if self.chatRoomUid == nil {
                    self.createRoom()
                    print("createRoom")
                }
            }
        })
    }
    
    func getDestinationInfo(){
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of:.value,with:{ (datasnapshot) in
            
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
            
        })
    }
    
    func getMessageList(){
        
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(.value,with:{ (datasnapshot) in
            
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.chatTableView.reloadData()
        })
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
