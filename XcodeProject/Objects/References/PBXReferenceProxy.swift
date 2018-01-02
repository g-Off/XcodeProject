//
//  PBXReferenceProxy.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXReferenceProxy: PBXReference {
	var fileType: String? //PBXFileType
	var remoteRef: PBXContainerItemProxy? {
		didSet {
			remoteRef?.parent = self
		}
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		remoteRef?.willMove(from: from)
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		remoteRef?.didMove(to: to)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.fileType = plist["fileType"]?.string
		self.remoteRef = objectCache.object(for: PBXObject.ID(rawValue: plist["remoteRef"]?.string)) as? PBXContainerItemProxy
		self.sourceTree = sourceTree
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: remoteRef)
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["fileType"] = fileType
		plist["remoteRef"] = remoteRef?.plistID
		return plist
	}
}
