//
//  PBXReferenceProxy.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXReferenceProxy: PBXReference {
	private enum CodingKeys: String, CodingKey {
		case fileType
		case remoteRef
	}

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
		self.remoteRef = objectCache.object(for: PBXGlobalID(rawValue: plist["remoteRef"]?.string)) as? PBXContainerItemProxy
		self.sourceTree = sourceTree
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: remoteRef)
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(fileType, forKey: .fileType)
		try container.encodeIfPresent(remoteRef, forKey: .remoteRef)
	}
}
