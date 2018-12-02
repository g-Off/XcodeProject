//
//  XCVersionGroup.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class XCVersionGroup: PBXGroup {
	var currentVersion: PBXFileReference? {
		didSet {
			currentVersion?.parent = self
		}
	}
	var versionGroupType: String?
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		currentVersion?.willMove(from: from)
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		currentVersion?.didMove(to: to)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let currentVersion = objectCache.object(for: PBXGlobalID(rawValue: plist["currentVersion"]?.string)) as? PBXFileReference,
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
