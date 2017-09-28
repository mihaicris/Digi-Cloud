//
//  Digi_Cloud_UITests.swift
//  Digi Cloud UITests
//
//  Created by Mihai Cristescu on 28/09/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import XCTest

class Digi_Cloud_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
