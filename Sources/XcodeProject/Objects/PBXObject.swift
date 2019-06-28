//
//  PBXObject.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-21.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXObject: Encodable {
	private enum CodingKeys: String, CodingKey {
		case isa
	}
	
	public let globalID: PBXGlobalID
	public internal(set) weak var parent: PBXObject? {
		willSet {
			willMove(from: parent)
		}
		didSet {
			didMove(to: parent)
		}
	}
	
	public required init(globalID: PBXGlobalID) {
		self.globalID = globalID
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(isa, forKey: .isa)
	}
	
	func willMove(from: PBXObject?) {
		guard let from = from else { return }
		from.parentProject?.objects[globalID] = nil
	}
	
	func didMove(to: PBXObject?) {
		guard let to = to else { return }
		to.parentProject?.objects[globalID] = self
	}
	
	// MARK: - Unarchiving
	func update(with plist: PropertyList, objectCache: ObjectCache) {
		// default implementation does nothing
	}
	
	// MARK: - Archiving
	var archiveComment: String {
		return String(describing: type(of: self))
	}
	
	func visit(_ visitor: ObjectVisitor) {
		visitor.visit(object: self)
	}
	
	var isa: String {
		return String(describing: type(of: self))
	}
	
	var plistID: PlistID {
		return PlistID(globalID, comment: archiveComment)
	}
	
	var archiveInPlistOnSingleLine: Bool {
		return false
	}
}

extension PBXObject: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(globalID)
	}
	
	public static func ==(lhs: PBXObject, rhs: PBXObject) -> Bool {
		return type(of: lhs) == type(of: rhs) && lhs.globalID == rhs.globalID
	}
}

public protocol PBXContainer {
	var name: String? { get }
}

struct PlistID: Encodable, CustomStringConvertible {
	public let objectID: PBXGlobalID
	public let comment: String?
	
	init(_ objectID: PBXGlobalID, comment: String?) {
		self.objectID = objectID
		if let comment = comment, comment.isEmpty {
			self.comment = nil
		} else {
			self.comment = comment
		}
	}
	
	public var description: String {
		var string = "\(objectID)"
		if let comment = comment {
			string += " /* \(comment) */"
		}
		return string
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(description)
	}
}

let types: [PBXObject.Type] = [
	PBXAggregateTarget.self,
	PBXBuildFile.self,
	PBXContainerItemProxy.self,
	PBXCopyFilesBuildPhase.self,
	PBXFileReference.self,
	PBXFrameworksBuildPhase.self,
	PBXGroup.self,
	PBXHeadersBuildPhase.self,
	PBXLegacyTarget.self,
	PBXNativeTarget.self,
	PBXProject.self,
	PBXReferenceProxy.self,
	PBXResourcesBuildPhase.self,
	PBXSourcesBuildPhase.self,
	PBXShellScriptBuildPhase.self,
	PBXTargetDependency.self,
	PBXVariantGroup.self,
	XCBuildConfiguration.self,
	XCConfigurationList.self,
	XCVersionGroup.self,
]
