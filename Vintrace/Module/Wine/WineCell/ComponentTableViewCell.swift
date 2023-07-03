//
//  ComponentTableViewCell.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import UIKit

class ComponentTableViewCell: UITableViewCell {

    @IBOutlet weak var componentCodeLabel: UILabel!
    @IBOutlet weak var componentDescriptionLabel: UILabel!
    @IBOutlet weak var componentQuantityLabel: UILabel!
    
    var componentModel: Component? {
        didSet {
            self.configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    private func configureCell() {
        
        self.componentCodeLabel.text = componentModel?.code
        self.componentDescriptionLabel.text = componentModel?.description
        self.componentQuantityLabel.text = "\(componentModel?.quantity ?? 0)"
    }
    
    
}
