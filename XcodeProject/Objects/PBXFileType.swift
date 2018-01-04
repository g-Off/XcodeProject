//
//  PBXFileType.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-21.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation
import CoreServices

public struct PBXFileType: Decodable {
	static var fileTypes: [PBXFileType] = loadFileTypes() ?? []
	private static func loadFileTypes() -> [PBXFileType]? {
		guard let url = Bundle(for: PBXObject.self).url(forResource: "FileTypes", withExtension: "plist") else { return nil }
		do {
			return try PropertyListDecoder().decode([PBXFileType].self, from: try Data(contentsOf: url))
		} catch {
			return nil
		}
	}
	var uniformType: String
	var xcodeType: String
	
	var isHeader: Bool {
		return uniformType == kUTTypeCHeader as String || uniformType == kUTTypeCPlusPlusHeader as String
	}
	
	var isSource: Bool {
		return UTTypeConformsTo(uniformType as CFString, kUTTypeSourceCode)
	}
}

public extension PBXFileType {
	static func fileType(fileExtension: String) -> PBXFileType? {
		guard let uniformType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeUnretainedValue() as String? else { return nil }
		return fileTypes.first {
			$0.uniformType == uniformType
		}
	}
	
	static func fileType(filePath: String) -> PBXFileType? {
		let fileExtension = (filePath as NSString).pathExtension
		return fileType(fileExtension: fileExtension)
	}
	
	static func fileType(reference: PBXFileReference) -> PBXFileType? {
		return fileType(filePath: reference.fileType.type)
	}
}

extension PBXFileType {
	var buildPhaseType: PBXBuildPhase.Type? {
		if isHeader {
			return PBXHeadersBuildPhase.self
		} else if isSource {
			return PBXSourcesBuildPhase.self
		} else {
			return nil
		}
	}
}
