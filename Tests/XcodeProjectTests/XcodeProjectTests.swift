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
	
	private func urlForProject(named: String) throws -> URL {
		var url = URL(fileURLWithPath: #file).deletingLastPathComponent()
		url.appendPathComponent("Fixtures", isDirectory: true)
		url.appendPathComponent(named, isDirectory: true)
		url.appendPathExtension("xcodeproj")
		return url
	}
	
	private var selfPath: URL {
		let fileURL = URL(fileURLWithPath: #file)
		let projectURL = URL(fileURLWithPath: "../../XcodeProject.xcodeproj/", isDirectory: true, relativeTo: fileURL).standardizedFileURL
		return projectURL
	}
	
	@inline(__always)
	func assertReadWriteProject(url: URL) throws {
		let projectFile = try ProjectFile(url: url)
		let archiver = PBXPListArchiver(projectFile: projectFile)
		let streamWriter = StringStreamWriter()
		try archiver.write(stream: streamWriter)
		
		let url = URL(fileURLWithPath: "project.pbxproj", relativeTo: projectFile.url)
		let data = try Data(contentsOf: url)
		let string = String(data: data, encoding: .utf8)
		
		if streamWriter.string != string {
			let failureURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(UUID().uuidString).pbxproj")
			try streamWriter.string.write(to: failureURL, atomically: true, encoding: .utf8)
			add(XCTAttachment(contentsOfFile: failureURL))
			
			XCTFail("Failed to generate matching output for \(url.lastPathComponent). Run ksdiff \(url.path) \(failureURL.path)")
		}
	}
	
	func testAggregateTarget() throws {
		try assertReadWriteProject(url: try urlForProject(named: "AggregateLibrary"))
	}
	
	func testPrivateProjectFolder() throws {
		guard let path = ProcessInfo.processInfo.environment["PRIVATE_PROJECTS"], !path.isEmpty else { return }
		let privateProjectsDir = URL(fileURLWithPath: path, isDirectory: true)
		let files = try FileManager.default.contentsOfDirectory(at: privateProjectsDir, includingPropertiesForKeys: nil)
		try files.filter { return $0.pathExtension == "xcodeproj" }.forEach {
			try assertReadWriteProject(url: $0)
		}
	}
}
