//
//  LintRuleTests.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-04-23.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import XCTest
@testable import XcodeProject

class LintRuleTests: XCTestCase {
	func testLintRules() {
		let xcodeprojURL = Bundle(for: type(of: self)).url(forResource: "blahblah", withExtension: ".xcodeproj", subdirectory: "Projects")!
		let projectFile = ProjectFile(url: xcodeprojURL)!
		projectFile.projectErrors.forEach {
			var projectError = $0
			try! projectError.repair()
		}
		
		let copyiedProjectURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(UUID().uuidString).xcodeproj")
		print(copyiedProjectURL.path)
		do {
			try projectFile.save(to: copyiedProjectURL)
		} catch let error {
			XCTFail(error.localizedDescription)
		}
	}
}
