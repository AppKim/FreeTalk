//
//  SignUpViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/01.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color : String!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let statusBar = UIView()
        /*
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(self.view.safeAreaInsets)
            m.height.equalTo(30)
        }
        */
        color = remoteConfig["splash_background"].stringValue
        //statusBar.backgroundColor = UIColor(hex: color)
        submitButton.backgroundColor = UIColor(hex: color)
        submitButton.layer.cornerRadius = 20
        cancelButton.backgroundColor = UIColor(hex: color)
        cancelButton.layer.cornerRadius = 20
        
        // action attache
        submitButton.addTarget(self, action: #selector(submitEvent), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        
        // detect tap
        imageView.isUserInteractionEnabled = true
        
        // instance create
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
    }
    
    
    // show image library
    @objc func imagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    

    // select image from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // confirm
    @objc func submitEvent(){
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            if error != nil{
                print(error!.localizedDescription)
            }
            
            let uid = user?.user.uid
            let storageRef = Storage.storage().reference().child("userImages").child(uid!)
            let databaseRef = Database.database().reference().child("users").child(uid!)
            
            
            guard let imageView = self.imageView.image else {
                return
            }
            
            guard let image = imageView.jpegData(compressionQuality: 0.1) else {
                print("Image Error")
                return
            }
            
            storageRef.putData(image, metadata: nil) { (data, error) in
                if error == nil, data != nil {
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            if let errCode = AuthErrorCode(rawValue: error!._code) {
                                switch errCode {
                                case .invalidEmail:
                                    self.showAlert("Enter a valid email.")
                                case .emailAlreadyInUse:
                                    self.showAlert("Email already in use.")
                                default:
                                    self.showAlert("Error: \(error!.localizedDescription)")
                                }
                                return
                            }
                        } else {
                            let values = ["userName":self.name.text!,"profileImageUrl":url?.absoluteString,"uid":Auth.auth().currentUser?.uid]
                            databaseRef.setValue(values) { (error, ref) in
                                if error == nil {
                                    let alert = UIAlertController(title: "確認", message: "登録しました。", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        let s = UIStoryboard(name: "LoginViewController", bundle: nil)
                                        let loginVC = s.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                        self.present(loginVC, animated: true, completion: nil)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                }
                else {
                    print("Failed to put data:", error!)
                }
            }
        }
        
    }
    
    
    @objc func cancelEvent(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(_ message: String) {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
        
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
