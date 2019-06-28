//
//  _PBXObjectEncoder+SingleValueContainer.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

extension _PBXObjectEncoder {
	final class SingleValueContainer {
		private let encoder: _PBXObjectEncoder
		var codingPath: [CodingKey]

		init(referencing encoder: _PBXObjectEncoder, codingPath: [CodingKey]) {
			self.encoder = encoder
			self.codingPath = codingPath
		}
	}
}

extension _PBXObjectEncoder.SingleValueContainer: SingleValueEncodingContainer {
	private func assertCanEncodeNewValue() {
		precondition(encoder.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
	}
	
	func encodeNil() throws {
		encoder.storage.pushValue(NSNull())
	}
	
	func encode(_ value: Bool) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: String) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSString(string: value.quotedString))
	}
	
	func encode(_ value: Double) throws {
		throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Unsupported type: \(type(of: value))"))
	}
	
	func encode(_ value: Float) throws {
		throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Unsupported type: \(type(of: value))"))
	}
	
	func encode(_ value: Int) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: Int8) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: Int16) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: Int32) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: Int64) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: UInt) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: UInt8) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: UInt16) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: UInt32) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode(_ value: UInt64) throws {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(NSNumber(value: value))
	}
	
	func encode<T>(_ value: T) throws where T: Encodable {
		assertCanEncodeNewValue()
		encoder.storage.pushValue(try encoder.box(value))
	}
}
