//
//  Destiny_ggUITests.swift
//  Destiny.ggUITests
//
//  Created by Daniel Megahan on 4/28/17.
//  Copyright © 2017 Daniel Megahan. All rights reserved.
//

import XCTest

class Destiny_ggUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLockUnlock() {
        let app = XCUIApplication();
        app.toolbars.buttons["Lock"].tap();
        XCTAssertNotNil(app.toolbars.buttons["Unlock"]);
        app.toolbars.buttons["Unlock"].tap();
        XCTAssertNotNil(app.toolbars.buttons["Lock"]);
    }
    
    func testSearchBarFunction(){
        
    }
    
    func testSwitchOrientationLandscape(){
        XCUIDevice.shared().orientation = .portrait
        XCUIDevice.shared().orientation = .landscapeLeft
        
        XCTAssert(XCUIDevice.shared().orientation == .landscapeLeft);
        //need to also assert that the constraints are correct (how do i do this)
    }
    
    func testSwitchOrientationPortrait(){
        XCUIDevice.shared().orientation = .landscapeLeft;
        XCUIDevice.shared().orientation = .portrait;
        XCTAssert(XCUIDevice.shared().orientation == .portrait);
    }
    
    func testVODsButtonPressed(){
        let app = XCUIApplication()
        XCTAssert(app.toolbars.buttons["VODs"].exists);
        app.toolbars.buttons["VODs"].tap()
        
        //test if we're in the VODs view controller
        XCTAssert(app.navigationBars["VODs"].exists);
        
        let tablesQuery = app.tables;
        let table = tablesQuery.element;
        XCTAssertNotNil(table);
        var cells = table.cells.allElementsBoundByIndex;
        XCTAssertNotNil(cells);
        //test selection
        cells[0].tap();
        cells[1].tap();
    }
    
    func testVODsPressedThenBack(){
        //there and back again
        
        let app = XCUIApplication()
        app.toolbars.buttons["VODs"].tap();
        
        //test that we're in the VODs view controller
        XCTAssert(app.navigationBars["VODs"].exists);
        
        XCTAssert(app.toolbars.buttons["Back"].exists);
        app.toolbars.buttons["Back"].tap();
        
        //test that we're back on the homepage
        XCTAssert(app.navigationBars["Homepage"].exists);
    }
}
