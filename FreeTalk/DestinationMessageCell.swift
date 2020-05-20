//
//  DestinationMessageCell.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/07.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

class DestinationMessageCell: UITableViewCell {

    @IBOutlet weak var destinationMessage: UITextView!
    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var destinationName: UILabel!
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
