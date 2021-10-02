//
//  ContentDetailTableViewController.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

class ContentDetailTableViewController: UITableViewController {
        
    // MARK:- IBOutlets -
    
    // MARK:- Variables -
    
    private let tableSerialQueue = DispatchQueue(label: "com.demo.serialQueue")
    
    private enum TableSections: NSInteger, CaseIterable {
        case contentDetail
    }
    
    var content:ContentCellInfoProtocol?
    
    // MARK:- Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ScreenTitles.contentDetail.rawValue
        
        initialSetup()
    }
    
    // MARK:- Helpers -
    
    private func initialSetup() {
        
        tableSetup()
        refreshTable()
    }
}

// MARK:- Table Helpers -

extension ContentDetailTableViewController {
    
    private func tableSetup() {

        self.tableView.estimatedRowHeight = 250
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: XibIdentifiers.defaultCell.rawValue)
        self.tableView.register(UINib(nibName: "ContentDetailTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: XibIdentifiers.contentDetailCell.rawValue)
    }
    
    private func refreshTable() {
        
        moveToMainThread{[weak self] in
            self?.tableSerialQueue.async {[weak self] in
                self?.moveToMainThread{[weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table view data source

extension ContentDetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (content != nil) ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.defaultCell.rawValue, for: indexPath)
        
        if let info = content,
           let tableCell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.contentDetailCell.rawValue, for: indexPath) as? ContentDetailTableViewCell {
            
            tableCell.populateInfo(info)
            
            cell = tableCell
        }
        
        cell.selectionStyle = .none

        return cell
    }
}
