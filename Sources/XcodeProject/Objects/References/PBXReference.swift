//
//  PBXReference.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-26.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public class PBXReference: PBXObject {
	public enum SourceTree: String {
		case absolute = "<absolute>"
		case group = "<group>"
		case project = "SOURCE_ROOT"
		case builtProducts = "BUILT_PRODUCTS_DIR"
		case developerDir = "DEVELOPER_DIR"
		case sdkRoot = "SDKROOT"
	}
	
	enum LineEnding: Int8 {
		case lf = 0
		case cr = 1
		case crlf = 2
	}
	
	public internal(set) var path: String?
	public internal(set) var name: String?
	public internal(set) var sourceTree: SourceTree?
    var usesTabs: Bool?
	var tabWidth: Int?
	var lineEnding: LineEnding?
	var indentWidth: Int?
	
	var buildFiles: [PBXBuildFile] {
		return _buildFiles.allObjects
	}
	private var _buildFiles = NSHashTable<PBXBuildFile>.weakObjects()
	func register(buildFile: PBXBuildFile) {
		_buildFiles.add(buildFile)
	}
	func unregister(buildFile: PBXBuildFile) {
		_buildFiles.remove(buildFile)
	}
	
	public var displayName: String {
		if let name = name {
			return name
		} else if let path = path {
			return URL(fileURLWithPath: path).lastPathComponent
		}
		return ""
	}
	
	public required init(globalID: PBXGlobalID) {
		super.init(globalID: globalID)
	}
	
	public required init(globalID: PBXGlobalID, name: String? = nil, path: String? = nil, sourceTree: SourceTree? = .group) {
		super.init(globalID: globalID)
		self.name = name
		self.path = path
		if let sourceTree = sourceTree {
			self.sourceTree = sourceTree
		} else if let path = path, (path as NSString).isAbsolutePath {
			self.sourceTree = .absolute
		} else {
			self.sourceTree = .group
		}
	}
	
	// MARK: - PList Unarchiving
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.path = plist["path"]?.string
		self.name = plist["name"]?.string
		self.sourceTree = SourceTree(rawValue: plist["sourceTree"]?.string ?? "")
		self.usesTabs = plist["usesTabs"]?.bool
		self.tabWidth = plist["tabWidth"]?.int
		if let lineEnding = plist["lineEnding"]?.int8 {
			self.lineEnding = LineEnding(rawValue: lineEnding)
		}
		self.indentWidth = plist["indentWidth"]?.int
	}
	
	override var archiveComment: String {
		if let name = name {
			return name
		} else if let path = path {
			return URL(fileURLWithPath: path).lastPathComponent
		}
		return ""
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["name"] = name
		plist["path"] = path
		plist["sourceTree"] = sourceTree?.rawValue
		plist["usesTabs"] = usesTabs
		plist["lineEnding"] = lineEnding?.rawValue
		plist["tabWidth"] = tabWidth
		plist["indentWidth"] = indentWidth
		return plist
	}
}
