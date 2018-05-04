//
//  PBXGroup+Sorting.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXGroup {
	func sort(recursive: Bool, by option: SortOption = .name) {
		sort(recursive: recursive, by: option.compare)
	}
	
	func sort(recursive: Bool, by areInIncreasingOrder: (PBXReference, PBXReference) -> Bool) {
		if recursive {
			children.compactMap { return $0 as? PBXGroup }.forEach {
				$0.sort(recursive: recursive, by: areInIncreasingOrder)
			}
		}
		children.sort(by: areInIncreasingOrder)
	}
}
