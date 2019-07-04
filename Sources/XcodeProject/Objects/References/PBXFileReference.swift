//
//  PBXFileReference.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public final class PBXFileReference: PBXReference {
	private enum CodingKeys: String, CodingKey {
		case fileEncoding
		case includeInIndex
		case xcLanguageSpecificationIdentifier
		case wrapsLines
		case lastKnownFileType
		case explicitFileType
	}

	public enum FileType {
		case lastKnown(String)
		case explicit(String)
		case unknown
		
		static func from(_ plist: PropertyList) -> FileType {
			if let lastKnownFileType = plist[CodingKeys.lastKnownFileType]?.string {
				return .lastKnown(lastKnownFileType)
			} else if let explicitFileType = plist[CodingKeys.explicitFileType]?.string {
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
	
	public private(set) var fileEncoding: String.Encoding? = nil
	public private(set) var includeInIndex: Bool?
	public private(set) var fileType: FileType = .unknown
	public private(set) var xcLanguageSpecificationIdentifier: String? // TODO: this should be a PBXFileType (xcode.lang.swift)
	public private(set) var wrapsLines: Bool?
	
	public required init(globalID: PBXGlobalID) {
		super.init(globalID: globalID)
	}
	
	public required init(globalID: PBXGlobalID, name: String? = nil, path: String? = nil, sourceTree: SourceTree? = .group) {
		super.init(globalID: PBXGlobalID(), name: name, path: path, sourceTree: sourceTree)
		if let path = path, let xcodeType = PBXFileType.fileType(filePath: path)?.xcodeType {
			self.fileType = .lastKnown(xcodeType)
			do {
				//var encoding: String.Encoding = .utf8
				//String(contentsOf: <#T##URL#>, usedEncoding: &<#T##String.Encoding#>)
			} catch {
				self.fileEncoding = .utf8
			}
		} else {
			self.fileType = .unknown
		}
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		if let encoding = plist[CodingKeys.fileEncoding]?.uint {
			self.fileEncoding = String.Encoding(rawValue: encoding)
		}
		
		self.includeInIndex = plist[CodingKeys.includeInIndex]?.bool
		self.fileType = FileType.from(plist)
		self.xcLanguageSpecificationIdentifier = plist[CodingKeys.xcLanguageSpecificationIdentifier]?.string
		self.wrapsLines = plist[CodingKeys.wrapsLines]?.bool
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(fileEncoding?.rawValue, forKey: .fileEncoding)
		try container.encodeIfPresent(includeInIndex, forKey: .includeInIndex)
		try container.encodeIfPresent(xcLanguageSpecificationIdentifier, forKey: .xcLanguageSpecificationIdentifier)
		try container.encodeIfPresent(wrapsLines, forKey: .wrapsLines)
		switch fileType {
		case .lastKnown(let type):
			try container.encodeIfPresent(type, forKey: .lastKnownFileType)
		case .explicit(let type):
			try container.encodeIfPresent(type, forKey: .explicitFileType)
		case .unknown:
			break
		}
	}
	
	override var archiveInPlistOnSingleLine: Bool {
		return true
	}
}
