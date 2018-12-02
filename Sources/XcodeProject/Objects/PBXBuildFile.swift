//
//  PBXBuildFile.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXBuildFile: PBXObject {
	
	var buildPhase: PBXBuildPhase? {
		return parent as? PBXBuildPhase
	}
	
	public internal(set) var fileRef: PBXReference? {
		didSet {
			oldValue?.unregister(buildFile: self)
			fileRef?.register(buildFile: self)
		}
	}
	var settings: [String: Any]?
	
	public convenience init(globalID: PBXGlobalID, fileReference: PBXReference) {
		self.init(globalID: globalID)
		fileRef = fileReference
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.fileRef = objectCache.object(for: PBXGlobalID(rawValue: plist["fileRef"]?.string))
		self.settings = plist["settings"]?.dictionary
	}
	
	override var archiveComment: String {
		guard let fileRef = fileRef, let parent = parent else {
			return super.archiveComment
		}
		return "\(fileRef.archiveComment) in \(parent.archiveComment)"
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: fileRef)
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["fileRef"] = fileRef?.plistID
		plist["settings"] = settings
		return plist
	}
	
	override var archiveInPlistOnSingleLine: Bool {
		return true
	}
}
