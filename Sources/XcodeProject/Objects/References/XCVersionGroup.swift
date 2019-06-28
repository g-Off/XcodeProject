//
//  XCVersionGroup.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class XCVersionGroup: PBXGroup {
	private enum CodingKeys: String, CodingKey {
		case currentVersion
		case versionGroupType
	}

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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(currentVersion?.plistID, forKey: .currentVersion)
		try container.encodeIfPresent(versionGroupType, forKey: .versionGroupType)
	}
}
