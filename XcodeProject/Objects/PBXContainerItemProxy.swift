//
//  PBXContainerItemProxy.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class PBXContainerItemProxy: PBXObject {
	enum ProxyType: Int8 {
		case nativeTarget = 1
		case reference = 2
		
		init?(string: String?) {
			guard let string = string, let intValue = Int8(string) else { return nil }
			self.init(rawValue: intValue)
		}
	}
	
	var containerPortal: PBXObject?
	var proxyType: ProxyType?
	var remoteGlobalIDString: String?
	var remoteInfo: String?
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let containerPortal = objectCache.object(for: GlobalID(rawValue: plist["containerPortal"]?.string)),
			let proxyType = ProxyType(string: plist["proxyType"]?.string),
			let remoteGlobalIDString = plist["remoteGlobalIDString"]?.string,
			let remoteInfo = plist["remoteInfo"]?.string
			else {
				fatalError()
		}
		self.containerPortal = containerPortal
		self.proxyType = proxyType
		self.remoteGlobalIDString = remoteGlobalIDString
		self.remoteInfo = remoteInfo
	}
	
	override public func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: containerPortal)
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["containerPortal"] = containerPortal?.plistID
		plist["proxyType"] = proxyType?.rawValue
		plist["remoteGlobalIDString"] = remoteGlobalIDString
		plist["remoteInfo"] = remoteInfo
		return plist
	}
}
