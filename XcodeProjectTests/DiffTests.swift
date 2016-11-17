//
//  DiffTests.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-04-15.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import XCTest
@testable import XcodeProject

class DiffTests: XCTestCase {
	func testDiff() {
		let url1 = Bundle(for: type(of: self)).url(forResource: "Project 1", withExtension: ".xcodeproj", subdirectory: "Projects/Diff")!
		let url2 = Bundle(for: type(of: self)).url(forResource: "Project 2", withExtension: ".xcodeproj", subdirectory: "Projects/Diff")!
		let left = ProjectFile(url: url1)!
		let right = ProjectFile(url: url2)!
		
		let diff = left.diff(other: right)
		print(diff)
	}
}
