//
//  ContentListTableViewControllerMock.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

protocol ContentListTableViewPresenter {
    
    var isShowingMoreLoadingIndicator:Bool {get set}
    var errorType:ContentsViewModelErrors {get set}
    var tableRowsCount:Int {get set}
    
    func setTitle(_ title:String?)
    func onViewDidLoad()
}

class ContentListTableViewPresenterMock: ContentListTableViewPresenter {
    
    // MARK:- Variables -
    
    var tableRowsCount:Int = 0

    var isShowingMoreLoadingIndicator: Bool = false
    var title:String?
    var viewDidLoadCalled:Bool = false
    var errorType: ContentsViewModelErrors = .others
    
    // MARK:- Methods -
    
    func setTitle(_ title:String?) {
        
        self.title = title
    }
    
    func onViewDidLoad() {
        viewDidLoadCalled = true
    }
}
