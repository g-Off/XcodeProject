//
//  XcodeProjectTests.swift
//  XcodeProjectTests
//
//  Created by Geoffrey Foster on 2016-11-16.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import XCTest
@testable import XcodeProject

class XcodeProjectTests: XCTestCase {
	
	@inline(__always)
	func assertReadWriteProject(xcodeprojURL: URL) {
		let projectFile = try! ProjectFile(url: xcodeprojURL)!
		
		let archiver = PBXPListArchiver(projectFile: projectFile)
		let streamWriter = StringStreamWriter()
		archiver.write(stream: streamWriter)
		
		let url = URL(fileURLWithPath: "project.pbxproj", relativeTo: projectFile.url)
		let data = try! Data(contentsOf: url)
		let string = String(data: data, encoding: .utf8)
		
		XCTAssertEqual(streamWriter.string, string, "Failed to generate matching output for \(xcodeprojURL.lastPathComponent)")
	}
	
	func testSelfArchive() {
		let xcodeproj = ProcessInfo.processInfo.environment["PROJECT"]!
		let xcodeprojURL = URL(fileURLWithPath: xcodeproj)
		assertReadWriteProject(xcodeprojURL: xcodeprojURL)
	}
	
	func testSelfSave() {
		let xcodeproj = ProcessInfo.processInfo.environment["PROJECT"]!
		let xcodeprojURL = URL(fileURLWithPath: xcodeproj)
		
		let copyiedProjectURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(UUID().uuidString).xcodeproj")
		
		do {
			try FileManager.default.copyItem(at: xcodeprojURL, to: copyiedProjectURL)
			let projectFile = try! ProjectFile(url: copyiedProjectURL)!
			projectFile.project.mainGroup.sort(recursive: true, by: .type)
			try projectFile.save()
		} catch (let error) {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testAggregateTarget() {
		let xcodeprojURL = Bundle(for: type(of: self)).url(forResource: "AggregateLibrary", withExtension: ".xcodeproj", subdirectory: "Projects")!
		assertReadWriteProject(xcodeprojURL: xcodeprojURL)
	}
	
	func testPrivateProjectFolder() {
		guard let path = ProcessInfo.processInfo.environment["PRIVATE_PROJECTS"], !path.isEmpty else { return }
		let privateProjectsDir = URL(fileURLWithPath: path, isDirectory: true)
		do {
			let files = try FileManager.default.contentsOfDirectory(at: privateProjectsDir, includingPropertiesForKeys: nil)
			files.filter {
				return $0.pathExtension == "xcodeproj"
				}.forEach {
					assertReadWriteProject(xcodeprojURL: $0)
			}
		} catch {
			XCTFail()
		}
	}
}
