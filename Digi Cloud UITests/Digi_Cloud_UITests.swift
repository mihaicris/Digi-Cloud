//
//  Digi_Cloud_UITests.swift
//  Digi Cloud UITests
//
//  Created by Mihai Cristescu on 28/09/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import XCTest

class Digi_Cloud_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddAccount() {
        app.buttons["Add Account"].tap()

        app.textFields["Username"].tap()
        app.textFields["Username"].typeText("mcristesc@yahoo.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("Demo99!")
        app.buttons["LOGIN"].tap()
        
        app.otherElements.containing(.staticText, identifier:"Digi Cloud for  Digi Storage").children(matching: .collectionView).element.tap()
        snapshot("-1-Locations-Overview")
       
        
    }
    
    func stub() {
        snapshot("-2-File-manager")
        snapshot("-3-Links")
        snapshot("-4-Share-in-DIGI-Storage")
        snapshot("-5-Content-preview")
    }
}
