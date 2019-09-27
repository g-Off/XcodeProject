//
//  PBXTargetDependency.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXTargetDependency: PBXProjectItem {
	//addPackageProductDependency
	//removePackageProductDependency
	private enum CodingKeys: String, CodingKey {
		case name
		case target
		case targetProxy
	}
	
	var name: String?
	var target: PBXTarget? {
		didSet {
			target?.parent = self
		}
	}
	var targetProxy: PBXContainerItemProxy? {
		didSet {
			targetProxy?.parent = self
		}
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		target?.willMove(from: from)
		targetProxy?.willMove(from: from)
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		target?.didMove(to: to)
		targetProxy?.didMove(to: to)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.name = plist[CodingKeys.name]?.string
		self.target = objectCache.object(for: plist[CodingKeys.target]?.globalID)
		self.targetProxy = objectCache.object(for: plist[CodingKeys.targetProxy]?.globalID)
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: target)
		visitor.visit(object: targetProxy)
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(name, forKey: .name)
		try container.encodeIfPresent(target, forKey: .target)
		try container.encodeIfPresent(targetProxy, forKey: .targetProxy)
	}
}
