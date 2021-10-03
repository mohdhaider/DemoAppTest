//
//  ContentsViewModel.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

class ContentsViewModel: NSObject {

    // MARK:- Variables -
    
    private let handler: NetworkHandler<ContentRequest> = NetworkHandler()
    
    private let helper = NetworkingHelpers()
    
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
    
    // For testing
    private var batchCount:Int = 0
    
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
            batchCount = 0
            clearContent()
        }
        
        let clearPreviousResults = (pageNum == 1) ? true : false
        
        let isAvailable = InternetHandler.shared.isInternetConnectionAvailable
        
        if isAvailable{
            
            self.callCodeBlock(afterDelay: 2.0) {[weak self] in
                
                if let selfObj = self {
                    
                    selfObj.helper.fetchContent(selfObj.handler, .fetchData(page: selfObj.pageNum)) {[weak self] (data, response, error) in
                        
                        self?.fetchRule = .processFinished
                        
                        do {
                            if let dataAvail = data {
                                
                                let response = try JSONDecoder().decode([ContentResult].self, from: dataAvail)
                                
                                if response.count > 0 {
                                    
                                    if clearPreviousResults {
                                        self?.results = []
                                        self?.batchCount = response.count
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
            }
        } else {
            fetchRule = .processFinished
            resetPageNumber()
            viewModelCallbacks.value = ContentsViewModelErrors.noInternetAvailable
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
    case others
    case taskApiInProgress
    case taskApiFailed
    case taskResultParsingFailed
    case clearResults
    case noTaskResults
    case noMoreResultsAvailable
    case noInternetAvailable
}

// MARK:- Tests Helpers -

extension ContentsViewModel {
    
    func checkNoInternetCase() {
        
        InternetHandler.shared.makeInternetNotAvailable()
        fetchRule = .processFinished
        getSearchResults()
    }
    
    func checkAlreadyDataFetchingTestCase() {
        
        fetchRule = .fetchingFreshResults
        getSearchResults()
    }
    
    func checkNoMoreDataForNextBatch() {
        
        fetchRule = .noMoreResultsAvailable
        getSearchResults(forNextPage: true)
    }
    
    func doesHaveDataForNextBatch() -> Bool {
        
        return results.count > 0 && results.count >= batchCount
    }
    
    func checkMoreDataApi() {
        
        InternetHandler.shared.startNetworkReachabilityObserver()
        InternetHandler.shared.makeInternetAvailable()
        
        fetchRule = .processFinished
        
        func firstBatch() {
            getSearchResults()
        }
        
        func secondBatch() {

            fetchRule = .noMoreResultsAvailable
            
            var canFetch = canFetchNextBatch()
            
            fetchRule = .noResultsAvailable
            
            canFetch = canFetchNextBatch()
            
            fetchRule = .fetchingNextBatch
            
            canFetch = canFetchNextBatch()
            
            fetchRule = .fetchingFreshResults
            
            canFetch = canFetchNextBatch()
            
            fetchRule = .processFinished
            
            canFetch = canFetchNextBatch()
            
            if canFetch {
                
                getSearchResults(forNextPage: true)
            }
        }
        
        viewModelCallbacks.bind {[weak self] result in
            
            self?.moveToMainThread({[weak self] in
                
                Logger.printLog("checkMoreDataApi >> result = \(String(describing: result))")
                
                if let records = result as? [ContentResult],
                   records.count > 0,
                   self?.pageNum ?? 0 == 1 {
                    secondBatch()
                }
            })
        }
        
        firstBatch()
    }
    
    func setupMockData(_ completion:(([ContentResult]?) -> Void)?) {
        
        performAsyncBlock {[weak self] in
            
            if let fileUrl = Bundle.main.url(forResource: "MockData", withExtension: "json"),
               let fileData = try? Data(contentsOf: fileUrl),
               let response = try? JSONDecoder().decode([ContentResult].self, from: fileData){
                
                self?.results = response
                self?.fetchRule = .processFinished
                self?.moveToMainThread({
                    completion?(response)
                })
            }
        }
    }
    
    func resetFetchRule() {
        fetchRule = .processFinished
    }
}
