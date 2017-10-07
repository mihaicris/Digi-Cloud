//
//  Digi_Cloud_UITests.swift
//  Digi Cloud UITests
//
//  Created by Mihai Cristescu on 28/09/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import XCTest

class Digi_Cloud_UITests: XCTestCase {
    
    var app: XCUIApplication = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddAccount() {
  
        let addAccountButton = app.buttons["Add Account"]
        
        addAccountButton.tap()
        app.textFields["Username"].tap()
        app.textFields["Username"].typeText("mcristesc@yahoo.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("Demo99!")
        app.buttons["LOGIN"].tap()

        let cellForDemoAccount = app.collectionViews.children(matching: .cell).containing(.staticText, identifier: "Demo Account").element
        let exists = NSPredicate(format: "exists == 1")
        
        expectation(for: exists, evaluatedWith: cellForDemoAccount, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        cellForDemoAccount.tap()
        
        let settingsButton = app.buttons["settings icon"]
        expectation(for: exists, evaluatedWith: settingsButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // LOGGED IN WITH DEMO ACCOUNT
        snapshot("1-Locations-Overview")
    }
    
    func stub() {
        snapshot("2-File-manager")
        snapshot("3-Links")
        snapshot("4-Share-in-DIGI-Storage")
        snapshot("5-Content-preview")
    }
}
