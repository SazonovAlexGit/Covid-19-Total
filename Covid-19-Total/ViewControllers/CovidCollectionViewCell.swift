//
//  CovidCollectionViewCell.swift
//  Covid-19-Total
//
//  Created by MAC on 26.04.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

class CovidCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var conformedLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayConfermedLabel: UILabel!
    @IBOutlet weak var dayRecoveredLabel: UILabel!
    @IBOutlet weak var dayDeathsLabel: UILabel!
    
    func configure() {
       contentView.layer.cornerRadius = 20
       contentView.layer.borderWidth = 1.0
       contentView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
       contentView.layer.masksToBounds = true
       layer.shadowColor = UIColor.gray.cgColor
       layer.shadowOffset = CGSize(width: 0, height: 2.0)
       layer.shadowRadius = 2.0
       layer.shadowOpacity = 0.5
       layer.masksToBounds = false
       layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
