//
//  ContentListTableViewController.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

protocol ContentCellInfoProtocol {
    var imageUrl:String? {get}
    var resultTitle:String? {get}
    var resultDescription:String? {get}
}

class ContentListTableViewController: UITableViewController {

    // MARK:- IBOutlets -
    
    private lazy var refreshControlTable:UIRefreshControl = {
        let rfrshCtrl = UIRefreshControl()
        rfrshCtrl.addTarget(self, action: #selector(self.handleRefresh) , for: .valueChanged)
        return rfrshCtrl
    }()
    
    // MARK:- Variables -
    
    private lazy var viewModel = ContentsViewModel()
    
    private let tableSerialQueue = DispatchQueue(label: "com.demo.serialQueue")
    
    private enum TableSections: NSInteger, CaseIterable {
        case contents
        case loadingIndicator
    }
    
    private var tableStatusMessage:String?
    
    // MARK:- Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ScreenTitles.contents.rawValue
        
        initialSetup()
    }
    
    // MARK:- Helpers -
    
    private func initialSetup() {
        
        registerNibs()
        refreshTable()
        dataBinding()
        fetchInitialData()
    }
    
    private func dataBinding() {
        
        func updateInfo(stopRefreshing stop:Bool, showMessage message: String?) {
            
            tableStatusMessage = message
            
            moveToMainThread {[weak self] in
                
                if stop {
                    self?.stopRefreshing()
                }
                
                if let message = message,
                   !message.isEmpty {
                    
                    UIAlertController.showAlertController(withTitle: nil,
                                                          alertMessage: message,
                                                          alertStyle: .alert,
                                                          withCancelTitle: nil,
                                                          alertActions: nil,
                                                          fromController: self,
                                                          sourceView: self?.view,
                                                          popupDirection: PopupArrowDirection.any())
                }
            }
        }
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let error = result as? ContentsViewModelErrors {
                
                print("error = \(error)")
                
                if error == .noInternetAvailable {
                    UIAlertController.showNoInternetAlert()
                    
                    updateInfo(stopRefreshing: true, showMessage: nil)
                    
                    self?.tableStatusMessage = AppMessages.noConnectionMessage.rawValue
                }
                else if error == .noTaskResults {
                    
                    updateInfo(stopRefreshing: true, showMessage: nil)
                }
                else if error == .noMoreResultsAvailable {
                    
                    updateInfo(stopRefreshing: true, showMessage: AppMessages.noMoreRecordsAvailable.rawValue)
                }
                else if error == .clearResults {
                    
                    if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                        updateInfo(stopRefreshing: false, showMessage: nil)
                    } else {
                        if self?.viewModel.isFetchingResults() ?? false || self?.viewModel.isFetchingNextBatch() ?? false {
                            updateInfo(stopRefreshing: false, showMessage: nil)
                        } else {
                            updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                        }
                    }
                }
                else {
                    if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                        updateInfo(stopRefreshing: true, showMessage: nil)
                    } else {
                        updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                    }
                }
            }
            else if let records = result as? [ContentCellInfoProtocol] {
                
                print("records = \(records.count)")
                                
                if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                    updateInfo(stopRefreshing: true, showMessage: nil)
                } else {
                    updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                }
            }
            else {
                if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                    updateInfo(stopRefreshing: true, showMessage: nil)
                } else {
                    updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                }
            }
            self?.refreshTable()
        }
    }
}

extension ContentListTableViewController {
 
    private func fetchInitialData() {
        
        startRefreshing()
        viewModel.getSearchResults()
    }
    
    @objc private func handleRefresh() {
        
        moveToMainThread{[weak self] in
            
            if let selfAvail = self {
                
                selfAvail.viewModel.getSearchResults()
            }
        }
    }
    
    private func startRefreshing() {

        moveToMainThread{[weak self] in
            
            if let selfObj = self,
                !selfObj.refreshControlTable.isRefreshing{
                
                selfObj.refreshControlTable.programaticallyBeginRefreshing(in: selfObj.tableView)
            }
        }
    }
    
    private func stopRefreshing() {

        moveToMainThread{[weak self] in
            
            if let selfObj = self,
               selfObj.refreshControlTable.isRefreshing {
                
                selfObj.refreshControlTable.programaticallyEndRefreshing(in: selfObj.tableView)
            }
        }
    }
}

// MARK:- Table Helpers -

extension ContentListTableViewController {
    
    private func registerNibs() {

        self.tableView.addSubview(refreshControlTable)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: XibIdentifiers.defaultCell)
        self.tableView.register(UINib(nibName: "StatusTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: XibIdentifiers.statusCell)
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

extension ContentListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TableSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case TableSections.contents.rawValue:
            
            return viewModel.numberOfRecords()
        case TableSections.loadingIndicator.rawValue:
            
            if viewModel.isFetchingNextBatch() {
                return 1
            }
            else if let message = tableStatusMessage, !message.isEmpty {
                return 1
            }
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.defaultCell, for: indexPath)

        switch indexPath.section {
            
        case TableSections.contents.rawValue:
        
            if let info = viewModel.recordForIndex(indexPath.row),
               let tableCell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.contentCell, for: indexPath) as? ContentTableViewCell {
                
                tableCell.populateInfo(info)
                
                cell = tableCell
            }
            
            let recordsCount = viewModel.numberOfRecords()
            
            if recordsCount > 0,
               indexPath.row == (recordsCount - 1),
               viewModel.canFetchNextBatch() {
                
                viewModel.getSearchResults(forNextPage: true)
            }
            
        case TableSections.loadingIndicator.rawValue:
            
            if let tableCell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.statusCell, for: indexPath) as? StatusTableViewCell {
                
                if viewModel.isFetchingNextBatch() {
                    tableCell.startLoading()
                }
                else {
                    tableCell.showMessage(tableStatusMessage)
                }
                
                cell = tableCell
            }
        default:
            break
        }
        
        cell.selectionStyle = .none

        return cell
    }
}

