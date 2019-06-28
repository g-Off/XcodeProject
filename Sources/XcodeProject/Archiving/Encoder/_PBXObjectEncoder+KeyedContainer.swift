//
//  _PBXObjectEncoder+KeyedContainer.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

extension _PBXObjectEncoder {
	final class KeyedContainer<Key> where Key: CodingKey {
		private let encoder: _PBXObjectEncoder
		var codingPath: [CodingKey]
		
		private var container: NSMutableDictionary
		
		init(referencing encoder: _PBXObjectEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
			self.encoder = encoder
			self.codingPath = codingPath
			self.container = container
		}
	}
}

extension _PBXObjectEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
	private func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
		return self.codingPath + [key]
	}
	
	func encodeNil(forKey key: Key) throws {
		container[key.stringValue] = NSNull()
	}
	
	func encode(_ value: String, forKey key: Key) throws {
		container[key.stringValue] = NSString(string: value.quotedString)
	}
	
	func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
		encoder.codingPath.append(key)
		defer { encoder.codingPath.removeLast() }
		container[key.stringValue] = try encoder.box(value)
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		fatalError()
	}
	
	func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		fatalError()
	}
	
	func superEncoder() -> Encoder {
		fatalError()
	}
	
	func superEncoder(forKey key: Key) -> Encoder {
		fatalError()
	}
}
