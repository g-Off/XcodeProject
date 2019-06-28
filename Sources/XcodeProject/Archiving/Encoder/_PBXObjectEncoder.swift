//
//  _PBXObjectEncoder.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

final class _PBXObjectEncoder: Encoder {
	var codingPath: [CodingKey] = []
	var userInfo: [CodingUserInfoKey: Any] = [:]
	
	var storage = _PBXObjectEncodingStorage()
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
		let topContainer: NSMutableDictionary
		if canEncodeNewValue {
			topContainer = storage.pushKeyedContainer()
		} else {
			guard let container = storage.top as? NSMutableDictionary else {
				preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
			}
			topContainer = container
		}
		
		return KeyedEncodingContainer(KeyedContainer<Key>(referencing: self, codingPath: codingPath, wrapping: topContainer))
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		let topContainer: NSMutableArray
		if canEncodeNewValue {
			topContainer = storage.pushUnkeyedContainer()
		} else {
			guard let container = storage.top as? NSMutableArray else {
				preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
			}
			topContainer = container
		}
		return UnkeyedContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		return SingleValueContainer(referencing: self, codingPath: codingPath)
	}
	
	var canEncodeNewValue: Bool {
		return storage.count == codingPath.count
	}
	
	func box<T>(_ value: T) throws -> NSObject where T: Encodable {
		if let value = value as? PBXObject {
			return NSString(string: value.plistID.description)
		} else {
			try value.encode(to: self)
			return storage.popContainer()
		}
	}
}
