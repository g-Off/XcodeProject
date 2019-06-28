//
//  _PBXObjectEncoder+UnkeyedContainer.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

extension _PBXObjectEncoder {
	final class UnkeyedContainer {
		private let encoder: _PBXObjectEncoder
		var codingPath: [CodingKey]
		
		private var container: NSMutableArray
		
		init(referencing encoder: _PBXObjectEncoder, codingPath: [CodingKey], wrapping container: NSMutableArray) {
			self.encoder = encoder
			self.codingPath = codingPath
			self.container = container
		}
	}
}

extension _PBXObjectEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
	private var nestedCodingPath: [CodingKey] {
		return codingPath + [AnyCodingKey(intValue: count)!]
	}
	
	var count: Int {
		return container.count
	}
	
	func encodeNil() throws {
		container.add(NSNull())
	}
	
	func encode(_ value: String) throws {
		container.add(NSString(string: value.quotedString))
	}
	
	func encode<T>(_ value: T) throws where T: Encodable {
		encoder.codingPath.append(AnyCodingKey(intValue: count)!)
		defer { encoder.codingPath.removeLast() }
		container.add(try encoder.box(value))
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		fatalError()
	}
	
	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		fatalError()
	}
	
	func superEncoder() -> Encoder {
		fatalError()
	}
}
