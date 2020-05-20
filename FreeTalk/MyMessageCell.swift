//
//  MyMessageCell.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/07.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

class MyMessageCell: UITableViewCell {

    @IBOutlet weak var myMessage: UITextView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var readCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
