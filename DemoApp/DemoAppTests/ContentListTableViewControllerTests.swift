//
//  ContentListTableViewControllerTests.swift
//  DemoAppTests
//
//  Created by Haider on 03/10/21.
//

import XCTest
@testable import DemoApp

class ContentListTableViewControllerTests: XCTestCase {

    let presenter = ContentListTableViewPresenterMock()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func makeContentsController() -> ContentListTableViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let sut = storyboard.instantiateViewController(identifier: "ContentListTableViewController") as! ContentListTableViewController
        
        sut.presenter = presenter
        sut.loadViewIfNeeded()
        return sut
    }

    func testCheckContentsViewLoading() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.title != nil)
    }
    
    func testCheckMockDataLoading() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()

        var activityExpectation: XCTestExpectation?
        
        let name = "Contents data loading"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                activityExpectation?.expectedFulfillmentCount = 2
                
                controller.checkMockDataLoading { success in
                    
                    if success {
                        activityExpectation?.fulfill()
                    }
                }
                
                controller.checkMockDataLoadingTestByViewModel {
                    activityExpectation?.fulfill()
                }
            }
        }
    }
    
    func testMockDataLoading() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.title != nil)
    }
    
    func testNoInternetAvailableCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "No internet available popup appear"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkingNoInternetAvailableCase()
                
                if (self?.presenter.errorType ?? .others) == .noInternetAvailable {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testNoTaskResultsCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "No tasks contents"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkingNoTaskResultsCase()
                
                if (self?.presenter.errorType ?? .others) == .noTaskResults {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testNoMoreResultsAvailableCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "No more results available"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkingNoMoreResultsAvailableCase()
                
                if (self?.presenter.errorType ?? .others) == .noMoreResultsAvailable {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testClearResultsCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Clear contents"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkingClearResultsCase()
                
                if (self?.presenter.errorType ?? .others) == .clearResults {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testOtherErrorsCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Unknown errors"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkingOtherErrorsCase()
                
                if (self?.presenter.errorType ?? .taskApiFailed) == .others {
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testManualRefreshCase() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Manual refresh case"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: networkRequestTimeout,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkManualRefreshCase {
                    
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
    
    func testCheckLoadingIndicatorWorking() throws {
        
        let controller = makeContentsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Check load more content loading indicator working"
        let expectationName = "\(name)"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 20,
                              exceptionName: expectationName) {[weak self] expectation in
                
                activityExpectation = expectation
                
                controller.checkLoadingIndicatorWorking {
                    
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
}
