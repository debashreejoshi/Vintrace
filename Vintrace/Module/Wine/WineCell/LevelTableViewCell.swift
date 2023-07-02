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
    
    var componentModel: Component? {
        didSet {
            self.configureCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func configureCell() {
        
        self.quantityNumberLabel.text = componentModel?.code
        self.quantityDescriptionLabel.text = componentModel?.description
       // self.componentQuantityLabel.text = "\(componentModel?.quantity)"
    }
    
}
