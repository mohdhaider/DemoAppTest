//
//  Router.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

struct Router {
    
    func showContentDetailScreen(forContent content:ContentCellInfoProtocol, fromController controller:UIViewController) {
       
        let detailController = ContentDetailTableViewController(nibName: "ContentDetailTableViewController", bundle: Bundle.main)
        detailController.content = content
        
        controller.navigationController?.pushViewController(detailController, animated: true)
    }
}
