//
//  ContentDetailTableViewCell.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

class ContentDetailTableViewCell: UITableViewCell {

    // MARK:- IBOutlets -
    
    @IBOutlet weak var contentImage:UIImageView!
    @IBOutlet weak var contentTitle:UILabel!
    @IBOutlet weak var contentDescription:UILabel!
    
    // MARK:- Cell Lifecycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- Helpers -
    
    func populateInfo(_ info:ContentCellInfoProtocol?) {
        
        contentImage.setImage(forUrl: info?.imageUrl, placeholderImage: UIImage.placeholderImageLarge())
        contentTitle.text = info?.resultTitle
        contentDescription.text = info?.resultDescription
    }
}
