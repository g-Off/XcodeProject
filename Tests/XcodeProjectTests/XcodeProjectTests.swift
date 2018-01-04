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
		let projectURL = URL(fileURLWithPath: "../../XcodeProject.xcodeproj", isDirectory: true, relativeTo: fileURL).standardizedFileURL
		return projectURL
	}
	
	@inline(__always)
	func assertReadWriteProject(url: URL) throws {
		guard let projectFile = try ProjectFile(url: url) else {
			XCTFail("Could not load project at \(url.path)")
			return
		}
		
		let archiver = PBXPListArchiver(projectFile: projectFile)
		let streamWriter = StringStreamWriter()
		archiver.write(stream: streamWriter)
		
		let url = URL(fileURLWithPath: "project.pbxproj", relativeTo: projectFile.url)
		let data = try! Data(contentsOf: url)
		let string = String(data: data, encoding: .utf8)
		
		if streamWriter.string != string {
			let failureURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(UUID().uuidString).pbxproj")
			try streamWriter.string.write(to: failureURL, atomically: true, encoding: .utf8)
			
			XCTFail("Failed to generate matching output for \(url.lastPathComponent). Run ksdiff \(url.path) \(failureURL.path)")
		}
	}
	
	func testSelfArchive() throws {
		// Disabled this test for now because Swift Package Manager generates project in a way that isn't great. The main group always has an empty comment associated with it, but Xcode doesn't do this >:(
		//try assertReadWriteProject(url: selfPath)
	}
	
	func testSelfSave() {
		let copiedProjectURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(UUID().uuidString).xcodeproj")
		
		do {
			try FileManager.default.copyItem(at: selfPath, to: copiedProjectURL)
			let projectFile = try! ProjectFile(url: copiedProjectURL)!
			projectFile.project.mainGroup.sort(recursive: true, by: .type)
			try projectFile.save()
		} catch (let error) {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testAggregateTarget() throws {
		try assertReadWriteProject(url: try urlForProject(named: "AggregateLibrary"))
	}
	
	func testPrivateProjectFolder() throws {
		guard let path = ProcessInfo.processInfo.environment["PRIVATE_PROJECTS"], !path.isEmpty else { return }
		let privateProjectsDir = URL(fileURLWithPath: path, isDirectory: true)
		do {
			let files = try FileManager.default.contentsOfDirectory(at: privateProjectsDir, includingPropertiesForKeys: nil)
			try files.filter { return $0.pathExtension == "xcodeproj" }.forEach {
				try assertReadWriteProject(url: $0)
			}
		} catch {
			XCTFail()
		}
	}
}
