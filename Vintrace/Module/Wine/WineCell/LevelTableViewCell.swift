//
//  LevelTableViewCell.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var quantityDescriptionLabel: UILabel!
    @IBOutlet weak var quantityNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        quantityView.layer.cornerRadius = 8
//        quantityView.clipsToBounds = true
//        quantityView.backgroundColor = .green
    }
    
    func configure(with key: String, value: Int) {
        
        self.quantityDescriptionLabel.text = key
        self.quantityNumberLabel.text = "\(value)"
      
    }
    
}
