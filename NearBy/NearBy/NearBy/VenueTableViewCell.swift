//
//  VenueTableViewCell.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import UIKit

class VenueTableViewCell: UITableViewCell {
    static let identifier = "VenueTableViewCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with venue: Venue) {
        nameLabel.text = venue.name
        cityLabel.text = venue.city ?? "Unknown city"
        addressLabel.text = venue.address ?? "No address"
    }
}
