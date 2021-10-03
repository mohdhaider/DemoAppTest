//
//  ContentDetailsTableViewPresenter.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

protocol ContentDetailsTableViewPresenter {
    
    var doesHaveContent:Bool {get set}
    
    func setTitle(_ title:String?)
    func onViewDidLoad()
}

class ContentDetailsTableViewPresenterMock: ContentDetailsTableViewPresenter {

    // MARK:- Variables -
    
    var title:String?
    var viewDidLoadCalled:Bool = false
    var doesHaveContent:Bool = false
    
    // MARK:- Methods -
    
    func setTitle(_ title:String?) {
        
        self.title = title
    }
    
    func onViewDidLoad() {
        viewDidLoadCalled = true
    }
}
