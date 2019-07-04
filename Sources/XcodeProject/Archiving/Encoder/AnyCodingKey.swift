//
//  AnyCodingKey.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2019-06-19.
//

import Foundation

struct AnyCodingKey: CodingKey, Equatable, Hashable {
	var stringValue: String
	var intValue: Int?
	
	init?(stringValue: String) {
		self.stringValue = stringValue
		self.intValue = nil
	}
	
	init?(intValue: Int) {
		self.stringValue = "\(intValue)"
		self.intValue = intValue
	}
	
	init(index: Int) {
		self.init(intValue: index)!
	}
	
	init<Key>(_ base: Key) where Key: CodingKey {
		if let intValue = base.intValue {
			self.init(intValue: intValue)!
		} else {
			self.init(stringValue: base.stringValue)!
		}
	}
}
