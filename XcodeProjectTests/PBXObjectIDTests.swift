//
//  PBXObjectIDTests.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-22.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import XCTest
@testable import XcodeProject

class PBXObjectIDTests: XCTestCase {

    func testIDGeneration() {
		var generator = PBXObject.ID.IDGenerator(userName: "XcodeProject", processId: 50_000, referenceDateFunc: { () -> UInt32 in
			return 0
		})
        let id = generator.next()
		XCTAssertEqual("8C50563000000000008D092D", id)
    }
}
