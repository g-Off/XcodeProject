//
//  PBXProject+Helpers.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-24.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public extension PBXProject {
	func addTarget(name: String, type: PBXNativeTarget.ProductType) {
		let target = PBXNativeTarget(globalID: GlobalID())
		target.name = name
		target.productName = name
		target.productType = type
		targets.append(target)
	}
}

extension PBXObject {
	var parentProject: PBXProject? {
		var parent = self.parent
		while parent != nil {
			if let parent = parent as? PBXProject {
				return parent
			}
			parent = parent?.parent
		}
		return nil
	}
}

extension PBXProject {
	func remove(fileReference: PBXFileReference) {
		fileReference.buildFiles.forEach {
			$0.buildPhase?.remove(file: $0)
		}
		if let group = fileReference.parent as? PBXGroup {
			group.remove(child: fileReference)
		}
	}
	
	func remove(reference: PBXReference) {
		//reference.
	}
}
