//
//  MainViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/05.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

// set UITableViewCell
class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileImageUrl: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var labelStatusMessage: UILabel! = UILabel()
    var statusMessageBackground: UIView! = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class PeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var array : [UserModel] = []
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var selectFriendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTable.separatorStyle = .none
        
        let databaseRef = Database.database().reference().child("users")
        
        databaseRef.observe(DataEventType.value) { (snapshot) in
            
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String:Any])
                
                if userModel.uid == myUid {
                    continue
                }
                self.array.append(userModel)
            }
            DispatchQueue.main.async {
                self.profileTable.reloadData();
            }
        }
        
        // MARK: - 修正必要
        /*
        let selectFriendButton = UIButton()
        view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view).offset(-90)
            m.right.equalTo(view).offset(-20)
            m.width.height.equalTo(50)
        }
        selectFriendButton.backgroundColor = UIColor.black*/
        selectFriendButton.addTarget(self, action: #selector(showSelectFriend), for: .touchUpInside)
        
        /*selectFriendButton.layer.cornerRadius = selectFriendButton.frame.size.width/2
        selectFriendButton.layer.masksToBounds = true*/
    }
    
    @objc func showSelectFriend(){
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cells", for: indexPath) as! ProfileCell
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        
        let statusMessageLabel = cell.labelStatusMessage!
        let statusMessageBackground = cell.statusMessageBackground!
        
        
        cell.addSubview(statusMessageBackground)
        cell.addSubview(statusMessageLabel)
        
        statusMessageLabel.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
        }
        if let statusMessage = array[indexPath.row].statusMessage{
            statusMessageLabel.text = statusMessage
        }
        
        statusMessageBackground.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(10)
            m.centerY.equalTo(cell)
            if let count = statusMessageLabel.text?.count{
                m.width.equalTo(count * 10)
            }else{
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        statusMessageBackground.backgroundColor = UIColor.gray
        
        
        
        cell.profileImageUrl.layer.cornerRadius =  cell.profileImageUrl.frame.size.width/2
        cell.profileImageUrl.clipsToBounds = true
        cell.profileImageUrl.kf.setImage(with: url)
        cell.userName.text = array[indexPath.row].userName
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = UIStoryboard(name: "ChatViewController", bundle: nil)
        let chatVC = s.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
