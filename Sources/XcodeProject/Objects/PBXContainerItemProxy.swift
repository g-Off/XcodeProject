//
//  PBXContainerItemProxy.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class PBXContainerItemProxy: PBXContainerItem {
	private enum CodingKeys: String, CodingKey {
		case containerPortal
		case proxyType
		case remoteGlobalIDString
		case remoteInfo
	}

	enum ProxyType: Int8, Encodable {
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
			let containerPortal = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.containerPortal]?.string)),
			let proxyType = ProxyType(string: plist[CodingKeys.proxyType]?.string),
			let remoteGlobalIDString = plist[CodingKeys.remoteGlobalIDString]?.string,
			let remoteInfo = plist[CodingKeys.remoteInfo]?.string
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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(containerPortal, forKey: .containerPortal)
		try container.encodeIfPresent(proxyType, forKey: .proxyType)
		try container.encodeIfPresent(remoteGlobalIDString, forKey: .remoteGlobalIDString)
		try container.encodeIfPresent(remoteInfo, forKey: .remoteInfo)
	}
}
