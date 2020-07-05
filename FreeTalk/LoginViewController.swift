//
//  LoginViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/01.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            // エラー処理
            print("Error: \(error)")
        }
        /*
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view.safeAreaInsets)
            m.height.equalTo(30)
            
        }
        */
        color = remoteConfig["splash_background"].stringValue
        
        //statusBar.backgroundColor = UIColor(hex: color)
        signinButton.backgroundColor = UIColor(hex: color)
        signinButton.layer.cornerRadius = 20
        signupButton.backgroundColor = UIColor(hex: color)
        signupButton.layer.cornerRadius = 20
        
        // action attache
        signupButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        
        //　listen for authentication status
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let s = UIStoryboard(name: "MainViewTabBarController", bundle: nil)
                let mainVC = s.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    // signup
    @objc func presentSignup(){
        
        let s = UIStoryboard(name: "SignUpViewController", bundle: nil)
        let signUpVC = s.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.present(signUpVC, animated: true, completion: nil)
        
    }
    
    //　login
    @objc func loginEvent(){
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                          switch errCode {
                            case .invalidEmail:
                                self.showAlert("User account not found. Try registering")
                            case .wrongPassword:
                                self.showAlert("Incorrect username/password combination")
                            default:
                                self.showAlert("Error:\(error!.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // login alert
    func showAlert(_ message: String) {
        
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
        
    }

}
