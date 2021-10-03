//
//  ContentDetailTableViewControllerTests.swift
//  DemoAppTests
//
//  Created by Haider on 03/10/21.
//

import XCTest
@testable import DemoApp

class ContentDetailTableViewControllerTests: XCTestCase {

    let presenter = ContentDetailsTableViewPresenterMock()
    
    func makeContentDetailsController() -> ContentDetailTableViewController {
        
        let controller = ContentDetailTableViewController(nibName: "ContentDetailTableViewController", bundle: Bundle.main)
        
        controller.presenter = presenter
        controller.loadViewIfNeeded()
        return controller
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCheckContentsViewLoading() throws {
        
        let controller = makeContentDetailsController()
        
        controller.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
        XCTAssertTrue(presenter.title != nil)
    }
    
    func testContentLoadingCheck() throws {
        
        let controller = makeContentDetailsController()
        
        controller.viewDidLoad()
        
        var activityExpectation: XCTestExpectation?
        
        let name = "Content data loading"
        let expectationName = "\(name) waiting"
        
        XCTContext.runActivity(named: name) { _ in
            
            waitForTimeout(for: 10,
                              exceptionName: expectationName) { expectation in
                
                activityExpectation = expectation
                
                controller.contentLoadingCheck {[weak self] in
                    self?.fullFillExpectation(&activityExpectation)
                }
            }
        }
    }
}
