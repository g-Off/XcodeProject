//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-06-23.
//

import Foundation

extension Sequence {
	func sorted<Value: Comparable>(by keyPath: KeyPath<Self.Element, Value>) -> [Self.Element] {
		return self.sorted { (lhs, rhs) -> Bool in
			lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
		}
	}
	
	func sorted<Value>(by keyPath: KeyPath<Self.Element, Value>, using comparator: (Value) -> (Value) -> ComparisonResult) -> [Self.Element] {
		return self.sorted { (lhs, rhs) -> Bool in
			comparator(lhs[keyPath: keyPath])(rhs[keyPath: keyPath]) == .orderedAscending
		}
	}
}
