//
//  PBXGlobalIDTests.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-22.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import XCTest
@testable import XcodeProject

class PBXGlobalIDTests: XCTestCase {
	func mockDateGenerator() -> Date {
		let components = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 2014, month: 07, day: 29, hour: 17, minute: 04, second: 20)
		let date = Calendar(identifier: .gregorian).date(from: components)
		return date!
	}
	
    func testIDGeneration() {
		var generator = PBXGlobalID.Generator(userName: "XcodeProject", processId: 50_000, hostId: 1234567890, random: 723, referenceDateGenerator: mockDateGenerator)
		XCTAssertEqual("8C5002D419880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D519880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D619880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D719880B94009602D2", generator.next())
    }
}
