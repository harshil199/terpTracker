//
//  customTableViewCell.swift
//  Tracker
//
//  Created by Harshil Patel on 4/24/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//

import UIKit

class customTableViewCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setLabels(name:String, date:String){
        nameLabel.text = name
        dateLabel.text = date
    }

}
