//
//  StatusTableViewCell.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    // MARK:- IBOutlets -
    
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    @IBOutlet weak var statusLabel:UILabel!
    
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
    
    func startLoading() {
        
        loadingIndicator.startAnimating()
        statusLabel.isHidden = true
        statusLabel.text = nil
    }
    
    func showMessage(_ message:String?) {
        
        loadingIndicator.stopAnimating()
        statusLabel.isHidden = false
        statusLabel.text = message
    }
}
