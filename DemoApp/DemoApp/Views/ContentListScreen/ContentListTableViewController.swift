//
//  ContentListTableViewController.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit
import ImageDownloader

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
    
    var presenter:ContentListTableViewPresenter?
    
    // MARK:- Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ScreenTitles.contents.rawValue
        
        presenter?.setTitle(self.title)
        presenter?.onViewDidLoad()
        
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
                
                Logger.printLog("error = \(error)")
                
                if error == .noInternetAvailable {
                    UIAlertController.showNoInternetAlert()
                    
                    self?.presenter?.errorType = .noInternetAvailable
                    
                    updateInfo(stopRefreshing: true, showMessage: nil)
                    
                    self?.tableStatusMessage = AppMessages.noConnectionMessage.rawValue
                }
                else if error == .noTaskResults {
                    
                    self?.presenter?.errorType = .noTaskResults
                    
                    updateInfo(stopRefreshing: true, showMessage: nil)
                }
                else if error == .noMoreResultsAvailable {
                    
                    self?.presenter?.errorType = .noMoreResultsAvailable
                    
                    updateInfo(stopRefreshing: true, showMessage: AppMessages.noMoreRecordsAvailable.rawValue)
                }
                else if error == .clearResults {
                    
                    self?.presenter?.errorType = .clearResults
                    
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
                    self?.presenter?.errorType = .others
                    
                    if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                        updateInfo(stopRefreshing: true, showMessage: nil)
                    } else {
                        updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                    }
                }
            }
            else if let records = result as? [ContentCellInfoProtocol] {
                
                Logger.printLog("records = \(records.count)")
                                
                self?.presenter?.tableRowsCount = self?.viewModel.numberOfRecords() ?? 0
                
                if self?.viewModel.numberOfRecords() ?? 0 > 0 {
                    updateInfo(stopRefreshing: true, showMessage: nil)
                } else {
                    updateInfo(stopRefreshing: true, showMessage: AppMessages.noDataAvailable.rawValue)
                }
            }
            else {
                self?.presenter?.tableRowsCount = self?.viewModel.numberOfRecords() ?? 0
                
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
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: XibIdentifiers.defaultCell.rawValue)
        self.tableView.register(UINib(nibName: "StatusTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: XibIdentifiers.statusCell.rawValue)
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

extension ContentListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TableSections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case TableSections.contents.rawValue:
            
            let count = viewModel.numberOfRecords()
            
            presenter?.tableRowsCount = count
            
            return count
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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.defaultCell.rawValue, for: indexPath)

        switch indexPath.section {
            
        case TableSections.contents.rawValue:
        
            if let info = viewModel.recordForIndex(indexPath.row),
               let tableCell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.contentCell.rawValue, for: indexPath) as? ContentTableViewCell {
                
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
            
            if let tableCell = tableView.dequeueReusableCell(withIdentifier: XibIdentifiers.statusCell.rawValue, for: indexPath) as? StatusTableViewCell {
                
                if viewModel.isFetchingNextBatch() {
                    
                    presenter?.isShowingMoreLoadingIndicator = true
                    
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

// MARK: - Table view delegate

extension ContentListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == TableSections.contents.rawValue,
           indexPath.row < viewModel.numberOfRecords(),
           let info = viewModel.recordForIndex(indexPath.row) {
           
            Router().showContentDetailScreen(forContent: info, fromController: self)
        }
    }
}

// MARK: - Table view data source prefetching

extension ContentListTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            
            if indexPath.section == TableSections.contents.rawValue,
               indexPath.row < viewModel.numberOfRecords(),
               let info = viewModel.recordForIndex(indexPath.row),
               let imageUrl = info.imageUrl{
                
                ImageDownloadManager.manager.load(
                    urlString: imageUrl as NSString) {[weak self] _, _ in
                        
                        self?.moveToMainThread({
                            
                            if let cell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell,
                               indexPath.section == TableSections.contents.rawValue,
                               indexPath.row < self?.viewModel.numberOfRecords() ?? 0,
                               let info = self?.viewModel.recordForIndex(indexPath.row) {
                                
                                cell.populateInfo(info)
                            }
                        })
                    }
            }
        }
    }
}

// MARK:- Test Helpers -

extension ContentListTableViewController {
    
    func checkMockDataLoading(_ completion:((Bool) -> Void)?) {
        
        viewModel.setupMockData {[weak self] results in
            
            self?.moveToMainThread({
                
                if let results = results {
                    
                    self?.refreshTable()
                    
                    self?.callCodeBlock(afterDelay: 3.0, {[weak self] in
                        
                        if let rowsCount = self?.presenter?.tableRowsCount,
                           rowsCount == results.count,
                           let visibleRows = self?.tableView.visibleCells as? [ContentTableViewCell],
                           visibleRows.count > 0 {
                            
                            completion?(true)
                        }
                    })
                }
            })
        }
    }
    
    func checkMockDataLoadingTestByViewModel(_ completion:(() -> Void)?) {
        
        viewModel.setupMockData {[weak self] results in
            
            self?.moveToMainThread({
                
                if let results = results {
                    
                    self?.viewModel.viewModelCallbacks.value = results
                    
                    self?.callCodeBlock(afterDelay: 3.0, {[weak self] in
                        
                        if let rowsCount = self?.presenter?.tableRowsCount,
                           rowsCount == results.count{
                            
                            completion?()
                        }
                    })
                }
            })
        }
    }
    
    func checkingNoInternetAvailableCase() {
        
        viewModel.viewModelCallbacks.value = ContentsViewModelErrors.noInternetAvailable
    }
    
    func checkingNoTaskResultsCase() {
        
        viewModel.viewModelCallbacks.value = ContentsViewModelErrors.noTaskResults
    }
    
    func checkingNoMoreResultsAvailableCase() {
        
        viewModel.viewModelCallbacks.value = ContentsViewModelErrors.noMoreResultsAvailable
    }
    
    func checkingClearResultsCase() {
        
        viewModel.viewModelCallbacks.value = ContentsViewModelErrors.clearResults
    }
    
    func checkingOtherErrorsCase() {
        
        viewModel.viewModelCallbacks.value = ContentsViewModelErrors.others
    }
    
    func checkManualRefreshCase(_ completion:(() -> Void)?) {
        
        handleRefresh()
        
        callCodeBlock(afterDelay: networkRequestTimeout) {[weak self] in
            
            if let presenter = self?.presenter,
               presenter.tableRowsCount > 0 ||
                (presenter.errorType == .noInternetAvailable || presenter.errorType == .noTaskResults) {
                
                completion?()
            }
        }
    }
    
    func checkLoadingIndicatorWorking(_ completion:(() -> Void)?) {
        
        viewModel.setupMockData {[weak self] results in
            
            self?.moveToMainThread({[weak self] in
                
                self?.refreshTable()
                
                self?.callCodeBlock(afterDelay: 2.0, {
                    
                    if let count = self?.tableView.numberOfRows(inSection: TableSections.contents.rawValue),
                       count > 0 {
                        
                        let lastIndex = IndexPath(row: (count - 1), section: TableSections.contents.rawValue)
                        
                        self?.viewModel.resetFetchRule()
                        
                        self?.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                        
                        self?.callCodeBlock(afterDelay: 2) {
                            
                            completion?()
                        }
                    }
                })
            })
        }
    }
}
