//
//  GroupChatRoomViewController.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/25.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").observeSingleEvent(of: .value) { (datasnapshot) in
            let dic = datasnapshot.value as! [String:AnyObject]
            print(dic.count)
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
