//
//  ContentTableViewCell.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    // MARK:- IBOutlets -
    
    @IBOutlet weak var resultImage:UIImageView!
    @IBOutlet weak var resultTitle:UILabel!
    @IBOutlet weak var resultDescription:UILabel!
    
    // MARK:- Cell Lifecycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        resultImage.layer.cornerRadius = 4.0
        resultImage.setImage(forUrl: nil, placeholderImage: UIImage.placeholderImage())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK:- Helper -
    
    func populateInfo(_ info:ContentCellInfoProtocol?) {
        
        resultImage.setImage(forUrl: info?.imageUrl, placeholderImage: UIImage.placeholderImage())
        resultTitle.text = info?.resultTitle
        resultDescription.text = info?.resultDescription
    }
}
