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

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileImageUrl: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
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
            // 데이터가쌓임
            //self.array.removeAll()
            
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
        
        URLSession.shared.dataTask(with: URL(string:array[indexPath.row].profileImageUrl!)!) { (data, response, error) in
            DispatchQueue.main.async {
                cell.profileImageUrl.image = UIImage(data: data!)
                cell.profileImageUrl.layer.cornerRadius =  cell.profileImageUrl.frame.size.width/2
                cell.profileImageUrl.clipsToBounds = true
            }
        }.resume()
        
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
