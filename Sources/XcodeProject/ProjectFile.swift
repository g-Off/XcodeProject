//
//  ProjectFile.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-16.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public enum ObjectVersion: UInt, Comparable, CaseIterable {
	public static func < (lhs: ObjectVersion, rhs: ObjectVersion) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	case xcode31 = 45
	case xcode32 = 46
	case xcode63 = 47
	case xcode8 = 48
	case xcode93 = 50
	case xcode10 = 51
}

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
	
	var archiveVersion: UInt = 1
	var objectVersion: ObjectVersion = .xcode8
	var classes: [AnyHashable: Any] = [:]
	var rootObject: PBXGlobalID
	/// The root project structure
	public private(set) var project: PBXProject
	
	let url: URL
	
	/// Initializes a new project file from the given URL
	///
	/// - Parameter url: Path to an xcodeproj file to be opened
	/// - Returns: A fully parsed project from the provided source or `nil` if an error happened
	public init(url: URL) throws {
		self.url = url
		let pbxproj = URL(fileURLWithPath: "project.pbxproj", relativeTo: url)
		let data = try Data(contentsOf: pbxproj)

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
}

extension ProjectFile {
	/// Saves the project file to disk with any modifications.
	///
	/// - Parameter to: Optional destination where the project file will be saved.
	/// - Throws:
	public func save(to destination: URL? = nil) throws {
		let destination = destination ?? url
		
		let dataStream = DataStreamWriter()
		let archiver = PBXPListArchiver(projectFile: self)
		try archiver.write(stream: dataStream)
		let pbxprojURL = URL(fileURLWithPath: "project.pbxproj", relativeTo: destination)
		try dataStream.data.write(to: pbxprojURL, options: [.atomic])
	}
}
