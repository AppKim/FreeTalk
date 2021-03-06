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
import SCLAlertView

class AccountViewController: UIViewController {
    
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var phonenumberView: UIView!
    @IBOutlet weak var statusmessageView: UIView!
    @IBOutlet weak var statusMessge: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    let databaseRef = Database.database().reference()
    var userModel : UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idView.layer.cornerRadius = 20
        nameView.layer.cornerRadius = 20
        phonenumberView.layer.cornerRadius = 20
        statusmessageView.layer.cornerRadius = 20
        editButton.layer.cornerRadius = 20
        logoutButton.layer.cornerRadius = 20
        
        statusMessge.addTarget(self, action: #selector(setStatusMessage), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(showEditAccount), for: .touchUpInside)
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
                let strLength = textField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                if strLength?.count == 0{
                    self.alert(title: "エラー", message: "１文字から入力可能です。", type: "error")
                }else{
                    let dic = ["statusMessage":textField.text!]
                    let uid = Auth.auth().currentUser?.uid
                    let databaseRef = Database.database().reference()
                    databaseRef.child("users").child(uid!).updateChildValues(dic)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
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
    
    @objc func showEditAccount(){
        self.performSegue(withIdentifier: "AccountEditSegue", sender: nil)
    }

    
    
    func alert(title:String,message:String,type:String){
        
        let alertVC = SCLAlertView()
        
        if type == "error"{
            alertVC.showTitle(
                title,
                subTitle: message,
                style: .error,
                closeButtonTitle: "確認",
                colorStyle: 0xFF5C5C,
                colorTextButton: 0xFFFFFF
            )
        }else if type == "edit"{
            alertVC.showTitle(
                title,
                subTitle: message,
                style: .edit,
                colorStyle: 0xDDDDFF,
                colorTextButton: 0xFFFFFF
            )
            
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
