//
//  SelectFriendViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/24.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageviewProfile: UIImageView!
    @IBOutlet weak var checkbox: BEMCheckBox!
}

class SelectFriendViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,BEMCheckBoxDelegate{
    @IBOutlet weak var createButton: UIButton!
    
    var users = Dictionary<String,Bool>()
    var array : [UserModel] = []
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        
        view.labelName.text = array[indexPath.row].userName
        view.imageviewProfile.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
        
        view.checkbox.delegate = self
        view.checkbox.tag = indexPath.row
        
        return view
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self.tableView.reloadData();
            }
        }
        
        createButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func didTap(_ checkBox: BEMCheckBox) {
        if(checkBox.on){
            
            users[self.array[checkBox.tag].uid!] = true
            
        }else{
            
            users.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
    }
    
    @objc func createRoom(){
        
        let myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as NSDictionary
        
        let databaseRef = Database.database().reference()
        databaseRef.child("chatrooms").childByAutoId().child("users").setValue(nsDic)
        
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
