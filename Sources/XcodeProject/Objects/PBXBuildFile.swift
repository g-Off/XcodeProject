//
//  PBXBuildFile.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXBuildFile: PBXProjectItem {
	private enum CodingKeys: String, CodingKey {
		case fileRef
		case settings
		case productRef
	}
	public enum Attribute: String, Comparable, Encodable {
		public static func < (lhs: PBXBuildFile.Attribute, rhs: PBXBuildFile.Attribute) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}
		
		case `public` = "Public"
		case `private` = "Private"
		case required = "Required"
		case `weak` = "Weak"
		case client = "Client"
		case server = "Server"
		case noCodegen = "no_codegen"
		case codeSignOnCopy = "CodeSignOnCopy"
		case removeHeadersOnCopy = "RemoveHeadersOnCopy"
	}
	struct Settings: Encodable {
		private enum CodingKeys: String, CodingKey {
			case attributes = "ATTRIBUTES"
			case compilerFlags = "COMPILER_FLAGS"
			case assetTags = "ASSET_TAGS"
		}
		
		var attributes: Set<Attribute>?
		var compilerFlags: String?
		
		init?(_ plist: [String: Any]?) {
			guard let plist = plist else { return nil }
			if let attributes = plist[CodingKeys.attributes.rawValue] as? [String] {
				self.attributes = Set(attributes.compactMap({ Attribute(rawValue: $0) }))
			}
			self.compilerFlags = plist[CodingKeys.compilerFlags.rawValue] as? String
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encodeIfPresent(attributes?.sorted(by: <), forKey: .attributes)
			try container.encodeIfPresent(compilerFlags, forKey: .compilerFlags)
		}
	}
	var buildPhase: PBXBuildPhase? {
		return parent as? PBXBuildPhase
	}
	
	public internal(set) var fileRef: PBXReference? {
		didSet {
			oldValue?.unregister(buildFile: self)
			fileRef?.register(buildFile: self)
		}
	}
	var settings: Settings?
	
	private(set) var productReference: PBXProductDependency?
	
	public convenience init(globalID: PBXGlobalID, fileReference: PBXReference) {
		self.init(globalID: globalID)
		fileRef = fileReference
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(fileRef, forKey: .fileRef)
		try container.encodeIfPresent(settings, forKey: .settings)
		try container.encodeIfPresent(productReference, forKey: .productRef)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.fileRef = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.fileRef]?.string))
		self.productReference = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.productRef]?.string))
		self.settings = Settings(plist["settings"]?.dictionary)
	}
	
	override var archiveComment: String {
		guard let parent = parent, let refComment = fileRef?.archiveComment ?? productReference?.archiveComment else {
			return super.archiveComment
		}
		return "\(refComment) in \(parent.archiveComment)"
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: fileRef)
		visitor.visit(object: productReference)
	}
	
	override var archiveInPlistOnSingleLine: Bool {
		return true
	}
}
