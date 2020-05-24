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

class SelectFriendViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var array : [UserModel] = []
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        
        view.labelName.text = array[indexPath.row].userName
        view.imageviewProfile.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
        
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
