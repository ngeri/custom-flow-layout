//
//  CustomCell.swift
//  CustomFlow
//
//  Created by Németh Gergely on 2018. 12. 19..
//  Copyright © 2018. Németh Gergely. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        visualEffectView.layer.cornerRadius = 12
        visualEffectView.layer.masksToBounds = true
        // corner radius
        layer.cornerRadius = 12
        // shadow


        addShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    private func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4.0
        clipsToBounds = false
    }
}
