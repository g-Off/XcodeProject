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
	struct FakeRandomGenerator: RandomNumberGenerator {
		private var value: UInt64 = 1234567890
		mutating func next() -> UInt64 {
			defer { value += 1 }
			return value
		}
	}
	
	func mockDateGenerator() -> Date {
		let components = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 2014, month: 07, day: 29, hour: 17, minute: 04, second: 20)
		let date = Calendar(identifier: .gregorian).date(from: components)
		return date!
	}
	
    func testIDGeneration() {
		let processId: pid_t = 50_000
		var randomNumberGenerator: RandomNumberGenerator = FakeRandomGenerator()
		var generator = PBXGlobalID.Generator(userName: "XcodeProject", processId: processId, random: &randomNumberGenerator, referenceDateGenerator: mockDateGenerator)
		XCTAssertEqual("8C5002D419880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D519880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D619880B94009602D2", generator.next())
		XCTAssertEqual("8C5002D719880B94009602D2", generator.next())
    }
}
