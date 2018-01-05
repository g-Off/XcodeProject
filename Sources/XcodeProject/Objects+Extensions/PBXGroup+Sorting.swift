//
//  PBXGroup+Sorting.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXGroup {
	enum SortOption: String {
		case name
		case type
		
		private func compareName(_ item1: PBXReference, _ item2: PBXReference) -> Bool {
			return item1.archiveComment.caseInsensitiveCompare(item2.archiveComment) == .orderedAscending
		}
		
		private func compareType(_ item1: PBXReference, _ item2: PBXReference) -> Bool {
			switch (item1, item2) {
			case (item1 as PBXGroup, item2 as PBXGroup):
				return compareName(item1, item2)
			case (item1 as PBXGroup, _):
				return true
			case (_, item2 as PBXGroup):
				return false
			case (let item1 as PBXFileReference, let item2 as PBXFileReference):
				return item1.fileType.type.caseInsensitiveCompare(item2.fileType.type) == .orderedAscending
			default:
				return false
			}
		}
		
		fileprivate var compare: (PBXReference, PBXReference) -> Bool {
			switch self {
			case .name:
				return compareName
			case .type:
				return compareType
			}
		}
	}
	
	func sort(recursive: Bool, by option: SortOption = .name) {
		sort(recursive: recursive, by: option.compare)
	}
	
	func sort(recursive: Bool, by areInIncreasingOrder: (PBXReference, PBXReference) -> Bool) {
		if recursive {
			children.flatMap { return $0 as? PBXGroup }.forEach {
				$0.sort(recursive: recursive, by: areInIncreasingOrder)
			}
		}
		children.sort(by: areInIncreasingOrder)
	}
}
