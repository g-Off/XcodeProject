//
//  PBXFileReference.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public class PBXFileReference: PBXReference {
	public enum FileType {
		case lastKnown(String)
		case explicit(String)
		case unknown
		
		static func from (_ plist: PropertyList) -> FileType {
			if let lastKnownFileType = plist["lastKnownFileType"]?.string {
				return .lastKnown(lastKnownFileType)
			} else if let explicitFileType = plist["explicitFileType"]?.string {
				return .explicit(explicitFileType)
			} else {
				return .unknown
			}
		}
		
		public var type: String {
			switch self {
			case .lastKnown(let string):
				return string
			case .explicit(let string):
				return string
			case .unknown:
				return ""
			}
		}
	}
	
	var fileEncoding: String.Encoding? = nil
	var includeInIndex: Bool?
	public private(set) var fileType: FileType = .unknown
	public internal(set) var xcLanguageSpecificationIdentifier: String? // TODO: this should be a PBXFileType (xcode.lang.swift)
	
	public convenience init(name: String, path: String? = nil, sourceTree: SourceTree? = .group, fileType: String) {
		self.init(name: name, path: path, sourceTree: sourceTree)
		self.fileType = .lastKnown(fileType)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		if let encoding = plist["fileEncoding"]?.uint {
			self.fileEncoding = String.Encoding(rawValue: encoding)
		}
		
		self.includeInIndex = plist["includeInIndex"]?.bool
		self.fileType = FileType.from(plist)
		self.xcLanguageSpecificationIdentifier = plist["xcLanguageSpecificationIdentifier"]?.string
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["fileEncoding"] = fileEncoding?.rawValue
		plist["includeInIndex"] = includeInIndex
		plist["xcLanguageSpecificationIdentifier"] = xcLanguageSpecificationIdentifier
		switch fileType {
		case .lastKnown(let type):
			plist["lastKnownFileType"] = type
		case .explicit(let type):
			plist["explicitFileType"] = type
		case .unknown:
			break
		}
		return plist
	}
	
	override var archiveInPlistOnSingleLine: Bool {
		return true
	}
}
