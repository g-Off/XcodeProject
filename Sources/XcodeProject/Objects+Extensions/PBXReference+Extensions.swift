//
//  PBXReference+Extensions.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

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
}
