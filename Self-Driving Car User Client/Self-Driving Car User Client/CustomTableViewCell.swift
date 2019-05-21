//
//  CustomTableViewCell.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 5/15/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func cellButtonClicked(cell: CustomTableViewCell)
}

class CustomTableViewCell: UITableViewCell {
    
    var delegate: CustomTableViewCellDelegate?
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func goButtonClicked(_ sender: Any) {
        delegate?.cellButtonClicked(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
