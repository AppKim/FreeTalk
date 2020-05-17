//
//  AccountViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/18.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet weak var statusMessge: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusMessge.addTarget(self, action: #selector(setStatusMessage), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func setStatusMessage(){
        
        let alertVC = UIAlertController(title: "ステータスメッセージ", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textfield) in
            textfield.placeholder = "ステータスメッセージを入力して下さい。"
        }
        alertVC.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            if let textField = alertVC.textFields?.first{
                let dic = ["statusMessage":textField.text!]
                let uid = Auth.auth().currentUser?.uid
                let databaseRef = Database.database().reference()
                databaseRef.child("users").child(uid!).updateChildValues(dic)
            }
        }))

        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertVC, animated: true, completion: nil)
        
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
