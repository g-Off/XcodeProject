//
//  PBXPListUnarchiver.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-06.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

class ObjectCache {
	let plist: [String: Any]
	let types: [PBXObject.Type]
	
	var objectCount: Int {
		return objects.count
	}
	
	public init(plist: [String: Any], types: [PBXObject.Type]) {
		self.plist = plist
		self.types = types
	}
	
	internal var objects: [GlobalID: PBXObject] = [:]
	
	func object<T: PBXObject>(for globalID: GlobalID?) -> T? {
		guard let globalID = globalID else { return nil }
		return cached(globalID: globalID, create: true) as? T
	}
	
	private func cached(globalID: GlobalID, create: Bool = false) -> PBXObject? {
		if let existing = objects[globalID] {
			return existing
		} else if create {
			return createObject(globalID: globalID)
		}
		return nil
	}
	
	private func createObject(globalID: GlobalID) -> PBXObject? {
		guard let objectPlist = plist[globalID.rawValue] as? [String: Any] else { return nil }
		guard let isa = objectPlist["isa"] as? String else { fatalError() }
		
		guard let type = types.first(where: { String(describing: $0) == isa }) else {
			//fatalError()
			return nil
		}
		
		let object = type.init(globalID: globalID)
		setCached(object: object, for: globalID)
		object.update(with: PropertyList(objectPlist), objectCache: self)
		
		return object
	}
	
	private func setCached(object: PBXObject?, for globalID: GlobalID) {
		guard let object = object else {
			return
		}
		objects[globalID] = object
	}
}
