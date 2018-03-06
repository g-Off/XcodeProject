//
//  PBXBuildPhase+Sorting.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXBuildPhase {
	func sort(by option: PBXReference.SortOption = .name) {
		sort(by: option.compare)
	}
	
	func sort(by areInIncreasingOrder: (PBXReference, PBXReference) -> Bool) {
		files.sort { (lhs, rhs) -> Bool in
			switch (lhs.fileRef, rhs.fileRef) {
			case (.some, .none), (.none, .none):
				return true
			case (.none, .some):
				return false
			case (.some(let lhsFile), .some(let rhsFile)):
				return areInIncreasingOrder(lhsFile, rhsFile)
			}
		}
	}
}
