//
//  ProjectFile.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-16.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public final class ProjectFile {
	enum Error: Swift.Error {
		case invalid
		case invalidPlist
		case missingProject
	}
	struct RootKey {
		static let classes = "classes"
		static let objects = "objects"
		static let objectVersion = "objectVersion"
		static let archiveVersion = "archiveVersion"
		static let rootObject = "rootObject"
	}
	
	public enum ObjectVersion: UInt {
		case xcode31 = 45
		case xcode32 = 46
		case xcode63 = 47
		case xcode8 = 48
		case xcode93 = 50
		case xcode10 = 51
	}
	
	var archiveVersion: UInt = 1
	var objectVersion: ObjectVersion = .xcode8
	var classes: [AnyHashable: Any] = [:]
	var rootObject: PBXGlobalID
	/// The root project structure
	public private(set) var project: PBXProject
	
	let url: URL
	let fileWrapper: FileWrapper
	
	/// Initializes a new project file from the given URL
	///
	/// - Parameter url: Path to an xcodeproj file to be opened
	/// - Returns: A fully parsed project from the provided source or `nil` if an error happened
	public init(url: URL) throws {
		self.url = url
		self.fileWrapper = try FileWrapper(url: url, options: [])
		guard fileWrapper.isDirectory else {
			throw CocoaError.error(.fileReadUnknown)
		}
		
		guard let pbxproj = fileWrapper.fileWrappers?["project.pbxproj"], pbxproj.isRegularFile else {
			throw CocoaError.error(.fileReadUnknown)
		}
		
		guard let data = pbxproj.regularFileContents else {
			throw Error.invalid
		}

		guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
			throw Error.invalidPlist
		}
		guard
			let archiveVersionString = plist[RootKey.archiveVersion] as? String, let archiveVersion = UInt(archiveVersionString),
			let objectVersionString = plist[RootKey.objectVersion] as? String, let objectVersionInt = UInt(objectVersionString), let objectVersion = ObjectVersion(rawValue: objectVersionInt),
			let rootObject = PBXGlobalID(rawValue: plist[RootKey.rootObject] as? String),
			let classes = plist[RootKey.classes] as? [AnyHashable: Any], classes.isEmpty
			else {
				throw Error.invalidPlist
		}
		self.archiveVersion = archiveVersion
		self.objectVersion = objectVersion
		self.rootObject = rootObject
		self.classes = classes
		guard let objects = plist[RootKey.objects] as? [String: Any] else {
			throw Error.invalidPlist
		}
		let objectCache = ObjectCache(plist: objects, types: types)
		guard let project = objectCache.object(for: rootObject) as? PBXProject else {
			throw Error.missingProject
		}
		project.path = url.path
		self.project = project
	}
	
	public func currentFileWrapper() throws -> FileWrapper {
		let currentFileWrapper = fileWrapper
		
		let oldPbxproj = currentFileWrapper.fileWrappers!["project.pbxproj"]!
		
		let dataStream = DataStreamWriter()
		let archiver = PBXPListArchiver(projectFile: self)
		try archiver.write(stream: dataStream)
		let newPbxproj = FileWrapper(regularFileWithContents: dataStream.data)
		newPbxproj.preferredFilename = "project.pbxproj"
		
		currentFileWrapper.removeFileWrapper(oldPbxproj)
		currentFileWrapper.addFileWrapper(newPbxproj)
		
		return currentFileWrapper
	}
}

extension ProjectFile {
	/// Saves the project file to disk with any modifications.
	///
	/// - Parameter to: Optional destination where the project file will be saved.
	/// - Throws:
	public func save(to destination: URL? = nil) throws {
		let destination = destination ?? url
		
		guard let oldPbxproj = fileWrapper.fileWrappers?["project.pbxproj"], oldPbxproj.isRegularFile else {
			throw CocoaError.error(.fileReadUnknown)
		}
		
		let dataStream = DataStreamWriter()
		let archiver = PBXPListArchiver(projectFile: self)
		try archiver.write(stream: dataStream)
		let newPbxproj = FileWrapper(regularFileWithContents: dataStream.data)
		newPbxproj.preferredFilename = "project.pbxproj"
		
		fileWrapper.removeFileWrapper(oldPbxproj)
		fileWrapper.addFileWrapper(newPbxproj)
		
		try fileWrapper.write(to: destination, options: [.atomic], originalContentsURL: nil)
	}
}
