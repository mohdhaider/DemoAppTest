//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by Haider on 02/10/21.
//

import XCTest
@testable import DemoApp

class DemoAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFreshContentApi() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let viewModel = ContentsViewModel()
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let message = result as? [ContentResult],
               message.count > 0 {
                
                self?.fullFillExpectation(&activityExpectation)
            }
            else if let error = result as? ContentsViewModelErrors {
                
                switch error {
                case .noInternetAvailable, .noTaskResults:
                    self?.fullFillExpectation(&activityExpectation)
                default:
                    break
                }
            }
        }
        
        let name = "Fetch new results"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 60,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                viewModel.getSearchResults()
            }
        }
    }
    
    func testMoreContentApi() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let viewModel = ContentsViewModel()
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let message = result as? [ContentResult],
               message.count > 0,
               viewModel.doesHaveDataForNextBatch() {

                self?.fullFillExpectation(&activityExpectation)
            }
            else if let error = result as? ContentsViewModelErrors {
                
                switch error {
                case .noInternetAvailable, .noMoreResultsAvailable:
                    self?.fullFillExpectation(&activityExpectation)
                default:
                    break
                }
            }
        }
        
        let name = "Fetch more results"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 120,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                viewModel.checkMoreDataApi()
            }
        }
    }
    
    func testContentApiWithNoInternet() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let viewModel = ContentsViewModel()
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let value = result as? ContentsViewModelErrors,
               value == .noInternetAvailable {
                
                self?.fullFillExpectation(&activityExpectation)
            }
        }
        
        let name = "Check no internet connection case"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 20,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                viewModel.checkNoInternetCase()
            }
        }
    }
    
    func testContentFetchRuleAlreadyDataFetching() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let viewModel = ContentsViewModel()
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let value = result as? ContentsViewModelErrors,
               value == .taskApiInProgress {
                
                self?.fullFillExpectation(&activityExpectation)
            }
        }
        
        let name = "Check condition for already fetching contents"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 5,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                viewModel.checkAlreadyDataFetchingTestCase()
            }
        }
    }
    
    func testCheckNoMoreDataForNextBatch() throws {
        
        var activityExpectation: XCTestExpectation?
        
        let viewModel = ContentsViewModel()
        
        viewModel.viewModelCallbacks.bind {[weak self] result in
            
            if let value = result as? ContentsViewModelErrors,
               value == .noMoreResultsAvailable {
                
                self?.fullFillExpectation(&activityExpectation)
            }
        }
        
        let name = "Check no more data foe next batch"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 60,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                viewModel.checkNoMoreDataForNextBatch()
            }
        }
    }
    
    func testNoInternetErrorCheck() throws {
        
        var checks = [NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorResourceUnavailable, NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed]
        
        let expectedSuccessCount = checks.count
        
        var checksCount = 0
        
        for code in checks {
            
            let error = NSError(domain: "com.sample", code: code, userInfo: nil) as Error
            
            if error.isNoInternetError() {
                
                checksCount += 1
            }
        }
        
        XCTAssertTrue(checksCount == expectedSuccessCount)
        
        checks.append(NSURLErrorZeroByteResource)
        
        var doesHaveNoNetworkCheckCode = false
        
        for code in checks {
            
            let error = NSError(domain: "com.sample", code: code, userInfo: nil) as Error
            
            if !error.isNoInternetError() {
                doesHaveNoNetworkCheckCode = true
                break
            }
        }
        
        XCTAssertTrue(doesHaveNoNetworkCheckCode)
    }
    
    func testImageViewChecks() {
        
        let imageView = UIImageView(image: nil)
        
        let placeholderImage = UIImage.placeholderImage()
        
        let largePlaceholderImage = UIImage.placeholderImage()
        
        imageView.setImage(forUrl: nil, placeholderImage: placeholderImage)
        
        XCTAssertTrue(imageView.image == placeholderImage)
        
        imageView.setImage(forUrl: nil, placeholderImage: largePlaceholderImage)
        
        XCTAssertTrue(imageView.image == largePlaceholderImage)
    }
    
    func testMainThreadChecker() {
        
        var activityExpectation: XCTestExpectation?
        
        waitForTimeout(for: 5, exceptionName: "Main thread checker") {[weak self] expectation in
            
            activityExpectation = expectation
            activityExpectation?.expectedFulfillmentCount = 2
            
            self?.performAsyncBlock {
                NSObject.moveToMainThread {
                    if Thread.isMainThread {
                        activityExpectation?.fulfill()
                    }
                }
            }
            
            self?.performAsyncBlock {[weak self] in
                self?.moveToMainThread {
                    if Thread.isMainThread {
                        activityExpectation?.fulfill()
                    }
                }
            }
        }
    }
}
