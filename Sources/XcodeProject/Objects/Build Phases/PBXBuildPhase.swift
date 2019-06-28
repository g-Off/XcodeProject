//
//  PBXBuildPhase.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-26.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXBuildPhase: PBXObject {
	private enum CodingKeys: String, CodingKey {
		case name
		case files
		case runOnlyForDeploymentPostprocessing
		case buildActionMask
	}

	class var defaultName: String {
		return ""
	}
	
	private var _name: String?
	
	public internal(set) var files: [PBXBuildFile] = [] {
		didSet {
			files.forEach { $0.parent = self }
		}
	}
	public var name: String {
		return _name ?? type(of: self).defaultName
	}
	var runOnlyForDeploymentPostprocessing: Bool?
	var buildActionMask: Int32 = Int32.max
	
	public func insert(contentsOf buildFiles: [PBXBuildFile], at index: Int) {
		files.insert(contentsOf: buildFiles, at: index)
	}
	
	public func remove(file: PBXBuildFile) {
		guard let index = files.firstIndex(of: file) else { return }
		files.remove(at: index)
	}
	
	public func remove(at index: Int) {
		files.remove(at: index)
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		files.forEach {
			$0.willMove(from: from)
		}
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		files.forEach {
			$0.didMove(to: to)
		}
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard let files = plist["files"]?.array else {
			fatalError()
		}
		self._name = plist["name"]?.string
		self.files = files.compactMap {
			let file: PBXBuildFile? = objectCache.object(for: PBXGlobalID(rawValue: $0))
			return file
		}
		
		self.runOnlyForDeploymentPostprocessing = plist["runOnlyForDeploymentPostprocessing"]?.bool
		
		if let v = plist["buildActionMask"]?.string, let buildActionMask = Int32(v) {
			self.buildActionMask = buildActionMask
		}
	}
	
	override var archiveComment: String {
		if let name = _name {
			return name
		}
		
		var name = String(describing: type(of: self))
		if let range = name.range(of: "PBX"), range.lowerBound == name.startIndex {
			name.removeSubrange(range)
		} else if let range = name.range(of: "XC"), range.lowerBound == name.startIndex {
			name.removeSubrange(range)
		}
		
		if let range = name.range(of: "BuildPhase", options: [.backwards]), range.upperBound == name.endIndex {
			name.removeSubrange(range)
		}
		
		return name
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		files.forEach {
			visitor.visit(object: $0)
		}
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(_name, forKey: .name)
		try container.encode(files, forKey: .files)
		try container.encodeIfPresent(runOnlyForDeploymentPostprocessing, forKey: .runOnlyForDeploymentPostprocessing)
		try container.encode(buildActionMask, forKey: .buildActionMask)
	}
}
