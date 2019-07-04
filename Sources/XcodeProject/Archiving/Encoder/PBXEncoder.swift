//
//  PBXEncoder.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-18.
//

import Foundation
import ObjectCoder

class PBXObjectEncoder {
	static let objectVersionKey = CodingUserInfoKey(rawValue: "objectVersion")!
	var objectVersion: ObjectVersion = .xcode93
	
	private static func quotedKey(_ codingKeys: [CodingKey]) -> CodingKey {
		let codingKey = codingKeys.last!
		if codingKey.intValue != nil { return codingKey }
		return AnyCodingKey(stringValue: codingKey.stringValue.quotedString)!
	}
	
	func encode(_ object: PBXObject) throws -> [String: AnyObject] {
		let options = ObjectEncoder<NSObject>.Options(
			keyEncodingStrategy: .custom(PBXObjectEncoder.quotedKey),
			userInfo: [PBXObjectEncoder.objectVersionKey: objectVersion]
		)
		let boxer = ObjectEncoder<NSObject>.Boxer()
		boxer.addWrapper { (object: PBXObject) -> NSObject in
			return NSString(string: object.plistID.description)
		}
		boxer.encodedString = { (value, _) in
			return NSString(string: value.quotedString)
		}
		let encoder = ObjectEncoder(options: options, boxer: boxer)
		try object.encode(to: encoder)
		return encoder.encoded as? [String: AnyObject] ?? [:]
		
//		let encoder = _PBXObjectEncoder()
//		encoder.userInfo = [PBXObjectEncoder.objectVersionKey: objectVersion]
//		try object.encode(to: encoder)
//		return encoder.storage.popContainer() as? [String: AnyObject] ?? [:]
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
