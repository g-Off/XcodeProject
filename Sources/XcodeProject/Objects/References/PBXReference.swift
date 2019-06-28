//
//  PBXReference.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-26.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public class PBXReference: PBXObject {
	private enum CodingKeys: String, CodingKey {
		case name
		case path
		case sourceTree
		case usesTabs
		case lineEnding
		case tabWidth
		case indentWidth
	}
	
	public enum SourceTree: String, Encodable {
		case absolute = "<absolute>"
		case group = "<group>"
		case project = "SOURCE_ROOT"
		case builtProducts = "BUILT_PRODUCTS_DIR"
		case developerDir = "DEVELOPER_DIR"
		case sdkRoot = "SDKROOT"
	}
	
	public enum LineEnding: Int8, Encodable {
		case lf = 0
		case cr = 1
		case crlf = 2
	}
	
	private struct WeakBuildFile: Hashable {
		weak var item: PBXBuildFile?
		
		static func ==(lhs: WeakBuildFile, rhs: WeakBuildFile) -> Bool {
			return lhs.item == rhs.item
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(item)
		}
	}
	
	public internal(set) var path: String?
	public internal(set) var name: String?
	public internal(set) var sourceTree: SourceTree?
	public internal(set) var usesTabs: Bool?
	public internal(set) var tabWidth: Int?
	public internal(set) var lineEnding: LineEnding?
	public internal(set) var indentWidth: Int?
	public var buildFiles: [PBXBuildFile] {
		return _buildFiles.compactMap { $0.item }
	}
	public var isGroup: Bool { return false }
	public var isLeaf: Bool { return true }
	
	private var _buildFiles: Array<WeakBuildFile> = []
	
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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(name, forKey: .name)
		try container.encodeIfPresent(path, forKey: .path)
		try container.encodeIfPresent(sourceTree, forKey: .sourceTree)
		try container.encodeIfPresent(usesTabs, forKey: .usesTabs)
		try container.encodeIfPresent(lineEnding, forKey: .lineEnding)
		try container.encodeIfPresent(tabWidth, forKey: .tabWidth)
		try container.encodeIfPresent(indentWidth, forKey: .indentWidth)
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
	
	func register(buildFile: PBXBuildFile) {
		_buildFiles.removeAll { $0.item == nil }
		_buildFiles.append(WeakBuildFile(item: buildFile))
	}
	
	func unregister(buildFile: PBXBuildFile) {
		_buildFiles.removeAll { $0.item == nil || $0.item == buildFile }
	}
}
