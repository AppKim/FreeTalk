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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTable.separatorStyle = .none
        
        let databaseRef = Database.database().reference().child("users")
        
        databaseRef.observe(DataEventType.value) { (snapshot) in
            
            // MARK: - 修正必要
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cells", for: indexPath) as! ProfileCell
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        
        let statusMessageLabel = cell.labelStatusMessage!
        let statusMessageBackground = cell.statusMessageBackground!
        
        cell.addSubview(statusMessageLabel)
        cell.addSubview(statusMessageBackground)
        
        statusMessageBackground.snp.makeConstraints { (m) in
            m.centerX.equalTo(cell.statusMessageBackground)
            m.centerY.equalTo(cell.statusMessageBackground)
            if let count = statusMessageLabel.text?.count{
                m.width.equalTo(count * 10)
            }else{
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        cell.statusMessageBackground.backgroundColor = UIColor.gray
        
        statusMessageLabel.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-20)
            m.centerY.equalTo(cell)
        }
        if let statusMessage = array[indexPath.row].statusMessage{
            statusMessageLabel.text = statusMessage
        }
        
        
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
