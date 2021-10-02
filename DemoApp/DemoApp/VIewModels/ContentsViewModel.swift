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
        
        guard (fetchRule != .fetchingFreshResults || fetchRule != .fetchingNextBatch) else {
            
            viewModelCallbacks.value = ContentsViewModelErrors.taskApiInProgress
            
            return
        }
        
        guard fetchRule != .noMoreResultsAvailable else {
            
            viewModelCallbacks.value = ContentsViewModelErrors.noTaskResults
            
            return
        }
        
        if nextPage {
            fetchRule = .fetchingNextBatch
            pageNum += 1
        } else {
            fetchRule = .fetchingFreshResults
            pageNum = 1
            clearContent()
        }
        
        let clearPreviousResults = (pageNum == 1) ? true : false
        
        networkManager.fetchContent(intractor, .fetchData(page: pageNum)) {[weak self] (data, response, error) in
            
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
                        self?.fetchRule = .noMoreResultsAvailable
                        self?.viewModelCallbacks.value = ContentsViewModelErrors.noTaskResults
                    }
                } else {
                    self?.viewModelCallbacks.value = ContentsViewModelErrors.taskApiFailed
                }
            } catch {
                print("error = \(error)")
                self?.viewModelCallbacks.value = ContentsViewModelErrors.taskResultParsingFailed
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
    
    private func isFetchingResults() -> Bool {
        
        return (fetchRule == .fetchingFreshResults) ? true : false
    }
    
    private func isFetchingNextBatch() -> Bool {
        
        return (fetchRule == .fetchingNextBatch) ? true : false
    }
    
    func canFetchNextBatch() -> Bool {
        
        if fetchRule == .noMoreResultsAvailable {
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
}
