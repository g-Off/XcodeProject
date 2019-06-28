//
//  _PBXObjectEncodingStorage.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

struct _PBXObjectEncodingStorage {
	private var containers: [NSObject] = []
	init() {}
	
	var count: Int {
		return containers.count
	}
	
	var top: NSObject? {
		return containers.last
	}
	
	mutating func pushKeyedContainer() -> NSMutableDictionary {
		let reference = NSMutableDictionary()
		containers.append(reference)
		return reference
	}
	
	mutating func pushUnkeyedContainer() -> NSMutableArray {
		let reference = NSMutableArray()
		containers.append(reference)
		return reference
	}
	
	@discardableResult
	mutating func pushValue(_ value: NSObject) -> NSObject {
		containers.append(value)
		return value
	}
	
	mutating func popContainer() -> NSObject {
		precondition(!containers.isEmpty, "Empty container stack.")
		return containers.popLast()!
	}
}
