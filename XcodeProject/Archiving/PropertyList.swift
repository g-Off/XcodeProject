//
//  PropertyList.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-03.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

struct PropertyList {
	let object: Any?
	
	init(_ object: Any?) {
		self.object = object
	}
	
	subscript(key: String) -> PropertyList? {
		guard let object = object as? [String: Any] else { return nil }
		guard let value = object[key] else { return nil }
		return PropertyList(value)
	}
	
	private func getTypedObject<T>() -> T? {
		return object as? T
	}
	
	var string: String? {
		return getTypedObject()
	}
	
	var array: [String]? {
		return getTypedObject()
	}
	
	var dictionary: [String: Any]? {
		return getTypedObject()
	}
	
	var bool: Bool? {
		guard let string = string else { return nil }
		return string == "1"
	}
	
	var int: Int? {
		guard let string = string else { return nil }
		return Int(string)
	}
	
	var int8: Int8? {
		guard let string = string else { return nil }
		return Int8(string)
	}
	
	var int16: Int16? {
		guard let string = string else { return nil }
		return Int16(string)
	}
	
	var int32: Int32? {
		guard let string = string else { return nil }
		return Int32(string)
	}
	
	var int64: Int64? {
		guard let string = string else { return nil }
		return Int64(string)
	}
	
	var uint: UInt? {
		guard let string = string else { return nil }
		return UInt(string)
	}
	
	var uint8: UInt8? {
		guard let string = string else { return nil }
		return UInt8(string)
	}
	
	var uint16: UInt16? {
		guard let string = string else { return nil }
		return UInt16(string)
	}
	
	var uint32: UInt32? {
		guard let string = string else { return nil }
		return UInt32(string)
	}
	
	var uint64: UInt64? {
		guard let string = string else { return nil }
		return UInt64(string)
	}
}
