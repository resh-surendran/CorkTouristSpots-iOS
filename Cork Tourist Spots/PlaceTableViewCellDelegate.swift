//
//  PlaceTableViewCellDelegate.swift
//  Cork Tourist Spots
//
//  Created by Reshma on 06/04/2019.
//  Copyright © 2019 UCC. All rights reserved.
//


protocol PlaceTableViewCellDelegate: class {
    func placeTableViewCellDidTapEdit(_ sender: PlaceTableViewCell)
    func placeTableViewCellDidTapDelete(_ sender: PlaceTableViewCell)
}
