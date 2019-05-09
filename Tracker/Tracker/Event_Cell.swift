//
//  Event_Cell.swift
//  Calender_Event
//
//  Created by Harshil Patel on 4/12/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit

class Event_Cell: UITableViewCell {

    @IBOutlet weak var lbl_Event_Name: UILabel!
    @IBOutlet weak var lbl_Event_Status: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

