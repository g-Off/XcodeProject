//
//  PBXObject.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-21.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXObject {
	public let globalID: GlobalID
	public internal(set) weak var parent: PBXObject?
	
	public required init(globalID: GlobalID) {
		self.globalID = globalID
	}
	
	// MARK: - Unarchiving
	func update(with plist: PropertyList, objectCache: ObjectCache) {
		// default implementation does nothing
	}
	
	// MARK: - Archiving
	var archiveComment: String {
		return String(describing: type(of:self))
	}
	
	func visit(_ visitor: ObjectVisitor) {
		visitor.visit(object: self)
	}
	
	var isa: String {
		return String(describing: type(of: self))
	}
	
	var plistID: PlistID {
		var plistID = "\(globalID.rawValue)"
		if archiveComment.isEmpty == false {
			plistID += " /* \(archiveComment) */"
		}
		return PlistID(rawValue: plistID)
	}
	
	var plistRepresentation: [String: Any?] {
		return ["isa": PlistISA(rawValue: isa)]
	}
	
	var archiveInPlistOnSingleLine: Bool {
		return false
	}
}

extension PBXObject: Hashable {
	public var hashValue: Int {
		return globalID.hashValue
	}
	
	public static func ==(lhs: PBXObject, rhs: PBXObject) -> Bool {
		return type(of: lhs) == type(of: rhs) && lhs.globalID == rhs.globalID
	}
}

protocol PBXContainer {
	var name: String? { get }
}

struct PlistID: CustomStringConvertible {
	public let rawValue: String
	
	public var description: String {
		return rawValue
	}
}

struct PlistISA: CustomStringConvertible {
	public let rawValue: String
	
	public var description: String {
		return rawValue
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
