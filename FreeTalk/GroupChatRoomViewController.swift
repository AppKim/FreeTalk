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
    @IBOutlet weak var inputMessageView: NSLayoutConstraint!
    var destinationRoom: String?
    var uid: String?
    var peopleCount: Int?
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments[indexPath.row].uid == uid {
            
            let myCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            myCell.myMessage.text = comments[indexPath.row].message
            myCell.selectionStyle = .none
            if let time = self.comments[indexPath.row].timestamp {
                myCell.timestamp.text = time.toDayTime
            }
            setReadCount(readCountLabel:myCell.readCount,position:indexPath.row)
            
            return myCell
            
        }else{
            
            let destinationUsers = users![comments[indexPath.row].uid!]
            
            let destinationCell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            
            destinationCell.destinationName.text = destinationUsers!["userName"] as! String
            destinationCell.destinationMessage.text = comments[indexPath.row].message
            destinationCell.selectionStyle = .none
            
            let imageUrl = destinationUsers!["profileImageUrl"] as! String
            
            let url = URL(string: (imageUrl))
            
            destinationCell.destinationImage.layer.cornerRadius = destinationCell.destinationImage.frame.size.height / 2
            destinationCell.destinationImage.clipsToBounds = true
            destinationCell.destinationImage.kf.setImage(with: url)
            
            if let time  = self.comments[indexPath.row].timestamp {
                destinationCell.timestamp.text = time.toDayTime
            }
            
            setReadCount(readCountLabel:destinationCell.readCount,position:indexPath.row)
            
            return destinationCell
        }
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
                var readUserDic: Dictionary<String,AnyObject> = [:]
                
                for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                    
                    let key = item.key
                    
                    let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                    let commentModify = ChatModel.Comment(JSON: item.value  as! [String:AnyObject])
                    commentModify?.readUsers[self.uid!] = true
                    readUserDic[key] = commentModify?.toJSON() as NSDictionary?
                    
                    //print(comment?.uid as! String)
                    self.comments.append(comment!)
                    self.chatTableView.reloadData()
                    
                }
                
                let nsDic = readUserDic as! NSDictionary
                if (!(self.comments.last?.readUsers.keys.contains(self.uid!))!){
                    
                    datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any]) { (err, ref) in
                        self.chatTableView.reloadData()
                        let lastIndexPath = IndexPath(row: self.comments.count-1, section: 0)
                        if self.comments.count > 0 {
                            self.chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                        }
                    }
                }else{
                    self.chatTableView.reloadData()
                    let lastIndexPath = IndexPath(row: self.comments.count-1, section: 0)
                    if self.comments.count > 0 {
                        self.chatTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                    }
                }
            }
        }

        
    }

    
    func setReadCount(readCountLabel:UILabel,position:Int){
        
        let readUsers = self.comments[position].readUsers.count
        
        if peopleCount == nil {
            
            databaseRef.child("chatrooms").child(destinationRoom!).child("users").observeSingleEvent(of: .value) { (datasnapshot) in
                
                let item = datasnapshot.value as! [String:AnyObject]
                self.peopleCount = item.count
                let noReadCount = self.peopleCount!-readUsers
                
                if noReadCount > 0 {
                    readCountLabel.isHidden = false
                    readCountLabel.text = String(noReadCount)
                }else{
                    readCountLabel.isHidden = true
                }
            }
            
        }else{
            
            guard let test = peopleCount else{
                return
            }
            
            let noReadCount = test - readUsers
            
            if noReadCount > 0 {
                readCountLabel.isHidden = false
                readCountLabel.text = String(noReadCount)
            }else{
                readCountLabel.isHidden = true
            }
            
        }
        
    }
    
    func initaializeHideKeyboard(){
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:Notification){
        
        let notiInfo = notification.userInfo!
        let keyboardSize = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let height = keyboardSize.height - self.view.safeAreaInsets.bottom
        
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: animationDuration) {
            self.inputMessageView.constant = -height
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(notification:Notification){
        
        let notiInfo = notification.userInfo!
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: animationDuration) {
            self.inputMessageView.constant = 0
            self.view.layoutIfNeeded()
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
