//
//  trackerApp_Unit.swift
//  trackerApp_Unit
//
//  Created by Simon Bundi on 24.05.22.
//

import XCTest
@testable import Runner

class trackerApp_Unit: XCTestCase {

    func checkHealthDataMethods() throws {
        let initalizedState = AppDelegate()
        initalizedState.healthPermission()
        XCTAssertNotNil(initalizedState.resultGlobal)
    }


}
