//
//  PBXEncoder.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-18.
//

import Foundation

class PBXObjectEncoder {
	static let objectVersionKey = CodingUserInfoKey(rawValue: "objectVersion")!
	var objectVersion: ObjectVersion = .xcode93
	
	func encode(_ object: PBXObject) throws -> [String: AnyObject] {
		let encoder = _PBXObjectEncoder()
		encoder.userInfo = [PBXObjectEncoder.objectVersionKey: objectVersion]
		try object.encode(to: encoder)
		return encoder.storage.popContainer() as? [String: AnyObject] ?? [:]
	}
}

extension Encoder {
	var objectVersion: ObjectVersion {
		return userInfo[PBXObjectEncoder.objectVersionKey] as? ObjectVersion ?? ObjectVersion.allCases.last!
	}
	
	// TODO: better name, but this will allow for encode(to:) function to be able to "smartly" decide to encode id's or objects
	var supportsCyclic: Bool {
		return self is _PBXObjectEncoder
	}
}
