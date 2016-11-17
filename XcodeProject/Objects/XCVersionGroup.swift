//
//  XCVersionGroup.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class XCVersionGroup: PBXGroup {
	var currentVersion: PBXFileReference? {
		didSet {
			currentVersion?.parent = self
		}
	}
	var versionGroupType: String?
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let currentVersion = objectCache.object(for: GlobalID(rawValue: plist["currentVersion"]?.string)) as? PBXFileReference,
			let versionGroupType = plist["versionGroupType"]?.string
			else {
				fatalError()
		}
		
		self.currentVersion = currentVersion
		self.versionGroupType = versionGroupType
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["currentVersion"] = currentVersion?.plistID
		plist["versionGroupType"] = versionGroupType
		return plist
	}
}
