//
//  PBXTargetDependency.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXTargetDependency: PBXObject {
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
		self.name = plist["name"]?.string
		self.target = objectCache.object(for: plist["target"]?.globalID)
		self.targetProxy = objectCache.object(for: plist["targetProxy"]?.globalID)
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: target)
		visitor.visit(object: targetProxy)
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["name"] = name
		plist["target"] = target?.plistID
		plist["targetProxy"] = targetProxy?.plistID
		return plist
	}
}
