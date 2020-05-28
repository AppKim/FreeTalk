//
//  ChatViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/06.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

extension Int {
    
    var toDayTime :String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
}

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
    
    let databasesRef = Database.database().reference()
    var db : DatabaseReference?
    var observe : UInt?
    var peopleCount :Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        chatTableView.separatorStyle = .none
        
        chatTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        chatTableView.register(UINib(nibName: "DestinationMessageCell", bundle: nil), forCellReuseIdentifier: "DestinationMessageCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.sendButton.isEnabled = false
        uid = Auth.auth().currentUser?.uid
        
        checkChatRoom()
        initaializeHideKeyboard()
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    // 画面から非表示になる直前に呼ばれる。
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
        db?.removeObserver(withHandle: observe!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if comments[indexPath.row].uid == uid {
            let myCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell",for: indexPath) as! MyMessageCell
            myCell.myMessage.text = self.comments[indexPath.row].message
            myCell.selectionStyle = .none
            if let time  = self.comments[indexPath.row].timestamp {
                myCell.timestamp.text = time.toDayTime
            }
            setReadCount(label: myCell.readCount, position: indexPath.row)
            return myCell
        }else{
            let destinationCell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell",for: indexPath) as! DestinationMessageCell
            destinationCell.destinationMessage.text = self.comments[indexPath.row].message
            destinationCell.destinationName.text = self.userModel?.userName
            destinationCell.selectionStyle = .none
            
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            
            destinationCell.destinationImage.layer.cornerRadius = destinationCell.destinationImage.frame.size.height / 2
            destinationCell.destinationImage.clipsToBounds = true
            destinationCell.destinationImage.kf.setImage(with: url)
            
            if let time  = self.comments[indexPath.row].timestamp {
                destinationCell.timestamp.text = time.toDayTime
            }
            
            setReadCount(label: destinationCell.readCount, position: indexPath.row)
            
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
        
        databasesRef.child("chatrooms").childByAutoId().setValue(createRoomInfo) { (error, ref) in
            if error == nil {
                self.checkChatRoom()
            }
        }
    }
    
    @objc func sendMessage(){
        let chatContent : Dictionary<String,Any> = [
            "uid":uid!,
            "message":message.text!,
            "timestamp": ServerValue.timestamp(),
        ]
        
        databasesRef.child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(chatContent) { (error, ref) in
            if error == nil {
                
                self.message.text = ""
                
            }else{
                print(error.debugDescription)
            }
        }
    }
    
    
    func checkChatRoom(){
        databasesRef.child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value,with:  { (datasnapshot) in
            if datasnapshot.value is NSNull{
                self.createRoom()
            }else {
                for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                    
                    if let chatRoomdic = item.value as? [String:AnyObject]{
                        
                        let chatModel = ChatModel(JSON: chatRoomdic)
                        
                        if chatModel?.users[self.destinationUid!] == true && chatModel?.users.count == 2{
                            
                            self.chatRoomUid  = item.key
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
        self.sendButton.isEnabled = true
    }
    
    func getDestinationInfo(){
        
        databasesRef.child("users").child(self.destinationUid!).observeSingleEvent(of:.value,with:{ (datasnapshot) in
            
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
            
        })
    }
    
    func getMessageList(){
        
        db = databasesRef.child("chatrooms").child(self.chatRoomUid!).child("comments")
        observe = db?.observe(.value,with:{ (datasnapshot) in
            
            if datasnapshot.hasChildren(){
                self.comments.removeAll()
                var readUserDic : Dictionary<String,AnyObject> = [:]
                
                for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                    let key = item.key as String
                    let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                    let commentMotify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                    commentMotify?.readUsers[self.uid!] = true
                    // ????
                    readUserDic[key] = commentMotify?.toJSON() as NSDictionary?
                    // ????
                    self.comments.append(comment!)
                }
                
                let nsDic = readUserDic as NSDictionary
                
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
        })
    }
    
    func setReadCount(label:UILabel,position: Int?){
        
        let readCount = self.comments[position!].readUsers.count
        
        if peopleCount == nil {
            
            databasesRef.child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: .value) { (datasnapshot) in
                
                let dic = datasnapshot.value as! [String:Any]
                self.peopleCount = dic.count
                let noReadCount = self.peopleCount! - readCount
                
                if(noReadCount > 0){
                    label.isHidden = false
                    label.text = String(noReadCount)
                }else{
                    label.isHidden = true
                }
            }
        }else{
            let noReadCount = peopleCount! - readCount
            
            if(noReadCount > 0){
                label.isHidden = false
                label.text = String(noReadCount)
            }else{
                label.isHidden = true
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
