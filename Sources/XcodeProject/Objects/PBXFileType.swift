//
//  PBXFileType.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2017-12-21.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation
import CoreServices

public struct PBXFileType {
	static var fileTypes: [PBXFileType] = [
		PBXFileType(uniformType: "com.apple.property-list", xcodeType: "text.plist.xml"),
		
		PBXFileType(uniformType: "public.c-header", xcodeType: "sourcecode.c.h"),
		PBXFileType(uniformType: "public.c-source", xcodeType: "sourcecode.c.c"),
		
		PBXFileType(uniformType: "public.swift-source", xcodeType: "sourcecode.swift"),
		
		PBXFileType(uniformType: "public.objective-c-source", xcodeType: "sourcecode.c.objc"),
		PBXFileType(uniformType: "public.objective-c-plus-plus-source", xcodeType: "sourcecode.cpp.objcpp"),
		
		PBXFileType(uniformType: "public.c-plus-plus-header", xcodeType: "sourcecode.cpp.h"),
		PBXFileType(uniformType: "public.c-plus-plus-source", xcodeType: "sourcecode.cpp.cpp")
	]
	var uniformType: String
	var xcodeType: String
	
    public init(uniformType: String, xcodeType: String) {
        self.uniformType = uniformType
        self.xcodeType = xcodeType
    }
	
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
