//
//  PlaceTableViewCell.swift
//  Cork Tourist Spots
//
//  Created by Reshma on 02/03/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeLabelOutlet: UILabel!
    @IBOutlet weak var addressLabelOutlet: UILabel!
    @IBOutlet weak var placeImageOutlet: UIImageView!
    
    weak var delegate: PlaceTableViewCellDelegate?
    @IBAction func editAction(_ sender: Any) {
        delegate?.placeTableViewCellDidTapEdit(self)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        delegate?.placeTableViewCellDidTapDelete(self
        )
    }
}
