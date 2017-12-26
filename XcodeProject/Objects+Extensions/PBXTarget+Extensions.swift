//
//  PBXTarget+Extensions.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-21.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public extension PBXTarget {
	func addFile(_ fileReference: PBXFileReference) {
		guard let buildPhase = buildPhase(for: fileReference) else { return }
		guard let globalId = parentProject?.generateGlobalId() else { return }
		let buildFile = PBXBuildFile(globalID: globalId, fileReference: fileReference)
		buildPhase.files.append(buildFile)
	}
	
	private func buildPhase(for fileReference: PBXFileReference) -> PBXBuildPhase? {
		guard let fileType = PBXFileType.fileType(reference: fileReference) else { return nil }
		if fileType.isHeader {
			let phase: PBXHeadersBuildPhase? = buildPhase()
			return phase
		} else if fileType.isSource {
			let phase: PBXSourcesBuildPhase? = buildPhase()
			return phase
		} else {
			return nil
		}
	}
	
	private func buildPhase<T: PBXBuildPhase>() -> T? {
		let buildPhase = buildPhases.first { (buildPhase) -> Bool in
			return buildPhase is T
		}
		return (buildPhase as? T) ?? addBuildPhase()
	}
}
