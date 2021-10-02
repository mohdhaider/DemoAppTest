//
//  ContentsViewModel.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

class ContentsViewModel: NSObject {

    // MARK:- Variables -
    
    private let intractor: NetworkIntractor<TaskRequest> = NetworkIntractor()
    
    private let networkManager = NetworkManager()
    
    var viewModelCallbacks = BindingBox<Any?>(nil)
    
    private enum FetchingRules {
        case processFinished
        case fetchingFreshResults
        case fetchingNextBatch
        case noResultsAvailable
        case noMoreResultsAvailable
    }
    
    private lazy var fetchRule:FetchingRules = .processFinished
    
    private var results = [ContentResult]()
    
    private var pageNum:Int = 0
    
    // MARK:- Helpers -
    
    func clearContent() {
        
        results = []
        viewModelCallbacks.value = ContentsViewModelErrors.clearResults
    }
    
    func getSearchResults(forNextPage nextPage:Bool = false) {
        
        if fetchRule == .fetchingFreshResults || fetchRule == .fetchingNextBatch {
            
            viewModelCallbacks.value = ContentsViewModelErrors.taskApiInProgress
            
            return
        }
        
        func resetPageNumber() {
            pageNum -= 1
        }
        
        if nextPage {
            
            guard fetchRule != .noMoreResultsAvailable else {
                
                viewModelCallbacks.value = ContentsViewModelErrors.noMoreResultsAvailable
                
                return
            }
            
            fetchRule = .fetchingNextBatch
            pageNum += 1
            viewModelCallbacks.value = ContentsViewModelErrors.taskApiInProgress
        } else {
            fetchRule = .fetchingFreshResults
            pageNum = 1
            clearContent()
        }
        
        let clearPreviousResults = (pageNum == 1) ? true : false
        
        InternetHandler.shared.checkNetworkAvailability {[weak self] isAvailable in
            
            if isAvailable,
            let selfObj = self{

                selfObj.callCodeBlock(afterDelay: 2.0) {
                    
                    selfObj.networkManager.fetchContent(selfObj.intractor, .fetchData(page: selfObj.pageNum)) {[weak self] (data, response, error) in
                        
                        self?.fetchRule = .processFinished
                        
                        do {
                            if let dataAvail = data {
                                
                                let response = try JSONDecoder().decode([ContentResult].self, from: dataAvail)
                                
                                if response.count > 0 {
                                    
                                    if clearPreviousResults {
                                        self?.results = []
                                    }
                                    
                                    self?.results.append(contentsOf: response)
                                    
                                    self?.viewModelCallbacks.value = self?.results ?? []
                                }
                                else {
                                    resetPageNumber()
                                    
                                    if clearPreviousResults {
                                        
                                        self?.fetchRule = .noResultsAvailable
                                        self?.viewModelCallbacks.value = ContentsViewModelErrors.noTaskResults
                                    } else {
                                        self?.fetchRule = .noMoreResultsAvailable
                                        self?.viewModelCallbacks.value = ContentsViewModelErrors.noMoreResultsAvailable
                                    }
                                }
                            } else {
                                
                                resetPageNumber()
                                
                                if let error = error,
                                   error.isNoInternetError() == true {
                                    
                                    self?.viewModelCallbacks.value = ContentsViewModelErrors.noInternetAvailable
                                } else {
                                    
                                    self?.viewModelCallbacks.value = ContentsViewModelErrors.taskApiFailed
                                }
                            }
                        } catch {
                            Logger.printLog("error = \(error)")
                            
                            resetPageNumber()
                            self?.viewModelCallbacks.value = ContentsViewModelErrors.taskResultParsingFailed
                        }
                    }
                }
            } else {
                self?.fetchRule = .processFinished
                resetPageNumber()
                self?.viewModelCallbacks.value = ContentsViewModelErrors.noInternetAvailable
            }
        }
    }
}

// MARK:- Records Helpers -

extension ContentsViewModel {
    
    func numberOfRecords() -> Int {
        return results.count
    }
    
    func recordForIndex(_ index: Int) -> ContentResult? {
        return (index < results.count) ? results[index] : nil
    }
    
    func isFetchingResults() -> Bool {
        
        return (fetchRule == .fetchingFreshResults) ? true : false
    }
    
    func isFetchingNextBatch() -> Bool {
        
        return (fetchRule == .fetchingNextBatch) ? true : false
    }
    
    func canFetchNextBatch() -> Bool {
        
        if fetchRule == .noMoreResultsAvailable || fetchRule == .noResultsAvailable {
            return false
        }
        else if isFetchingNextBatch() {
            return false
        }
        else if isFetchingResults() {
            return false
        }
        return true
    }
}

enum ContentsViewModelErrors: String, Error {
    case taskApiInProgress
    case taskApiFailed
    case taskResultParsingFailed
    case clearResults
    case noTaskResults
    case noMoreResultsAvailable
    case noInternetAvailable
}
