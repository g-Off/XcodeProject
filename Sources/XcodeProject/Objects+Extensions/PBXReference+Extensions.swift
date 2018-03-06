//
//  PBXReference+Extensions.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXReference {
	var parentGroup: PBXGroup? {
		return  parent as? PBXGroup
	}
}

public extension PBXReference {
	var url: URL? {
		guard let sourceTree = sourceTree else { return nil }
		guard let project = parentProject else { return nil }
		let filePath = path ?? ""
		switch sourceTree {
		case .absolute:
			return URL(fileURLWithPath: filePath)
		case .group:
			if let parent = parent as? PBXReference {
				return URL(fileURLWithPath: filePath, relativeTo: parent.url)
			} else if let projectURL = project.projectDirectory {
				return URL(fileURLWithPath: filePath, relativeTo: projectURL)
			}
		case .project:
			return URL(fileURLWithPath: filePath, relativeTo: project.projectDirectory)
		default:
			break
		}
		return nil
	}
	
	enum SortOption: String {
		case name
		case type
		
		private func compareName(_ lhs: PBXReference, _ rhs: PBXReference) -> Bool {
			return lhs.archiveComment.localizedStandardCompare(rhs.archiveComment) == .orderedAscending
		}
		
		private func compareType(_ lhs: PBXReference, _ rhs: PBXReference) -> Bool {
			switch (lhs, rhs) {
			case (lhs as PBXGroup, rhs as PBXGroup):
				return compareName(lhs, rhs)
			case (lhs as PBXGroup, _):
				return true
			case (_, rhs as PBXGroup):
				return false
			case (let lhs as PBXFileReference, let rhs as PBXFileReference):
				switch lhs.fileType.type.caseInsensitiveCompare(rhs.fileType.type) {
				case .orderedAscending:
					return true
				case .orderedSame:
					return compareName(lhs, rhs)
				case .orderedDescending:
					return false
				}
			default:
				return false
			}
		}
		
		public var compare: (PBXReference, PBXReference) -> Bool {
			switch self {
			case .name:
				return compareName
			case .type:
				return compareType
			}
		}
	}
}
