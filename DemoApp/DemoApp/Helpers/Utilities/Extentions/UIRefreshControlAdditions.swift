//
//  UIRefrershControlAdditions.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

extension UIRefreshControl {
    
    func programaticallyBeginRefreshing(in tableView: UITableView) {
        beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
    
    func programaticallyBeginRefreshing(in collectionView: UICollectionView) {
        beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        collectionView.setContentOffset(offsetPoint, animated: true)
    }

    func programaticallyEndRefreshing(in tableView: UITableView) {
        endRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: 0)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
    
    func programaticallyEndRefreshing(in collectionView: UICollectionView) {
        endRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: 0)
        collectionView.setContentOffset(offsetPoint, animated: true)
    }
}
