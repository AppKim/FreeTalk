//
//  AccountViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/18.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AccountViewController: UIViewController {
    
    @IBOutlet weak var statusMessge: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    let databaseRef = Database.database().reference()
    var userModel : UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        statusMessge.addTarget(self, action: #selector(setStatusMessage), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        getAccountInfo()
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func setStatusMessage(){
        
        let alertVC = UIAlertController(title: "ステータスメッセージ", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textfield) in
            
            if (self.userModel?.statusMessage!.isEmpty)!{
                textfield.placeholder = "ステータスメッセージを入力して下さい。"
            }else{
                textfield.text = self.userModel?.statusMessage
            }
            
        }
        let okAction = UIAlertAction(title: "確認", style: .default, handler: { (action) in
            if let textField = alertVC.textFields?.first{
                let dic = ["statusMessage":textField.text!]
                let uid = Auth.auth().currentUser?.uid
                let databaseRef = Database.database().reference()
                databaseRef.child("users").child(uid!).updateChildValues(dic)
            }
        })
        // MARK: - Observer修正、入力したらボタン活性化に更新
        
        alertVC.addAction(okAction)
        okAction.isEnabled = false
        
        
        
        
        
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func getAccountInfo(){
        let currentUid = Auth.auth().currentUser?.uid
        databaseRef.child("users").child(currentUid!).observe(.value) { (datasnapshot) in
            
            self.userModel = UserModel()
            let userInfo = datasnapshot.value as! [String:Any]
            self.userModel?.setValuesForKeys(userInfo)
            
            guard let name = self.userModel?.userName else {
                return
            }
            guard let statusMessage = self.userModel?.statusMessage else {
                return
            }
            guard let imageUrl = self.userModel?.profileImageUrl else {
                return
            }
            
            let url = URL(string: imageUrl)
            
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
            self.profileImageView.clipsToBounds = true
            self.profileImageView.kf.setImage(with: url)
            self.nameLabel.text = name
            if statusMessage.isEmpty{
                self.statusMessageLabel.setTitle("ステータスメッセージ", for: .normal)
            }else{
                self.statusMessageLabel.setTitle(statusMessage, for: .normal)
            }
            
        }
    }
    
    @objc func logout(){
        
        do {
            
            try Auth.auth().signOut()
            
            let s = UIStoryboard(name: "LoginViewController", bundle: nil)
            let loginVC = s.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            
        } catch  {
            print("error")
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
