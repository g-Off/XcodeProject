//
//  PBXProject.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public final class PBXProject: PBXObject, PBXContainer {
	private enum CodingKeys: String, CodingKey {
		case attributes
		case buildConfigurationList
		case compatibilityVersion
		case developmentRegion
		case hasScannedForEncodings
		case knownRegions
		case mainGroup
		case packageReferences
		case productRefGroup
		case projectDirPath
		case projectReferences
		case projectRoot
		case targets
	}
	
	public class Attributes: Encodable {
		public enum Value: Encodable {
			case string(String)
			case array([Value])
			case dictionary([String: Value])
			
			public func encode(to encoder: Encoder) throws {
				switch self {
				case .string(let string):
					var container = encoder.singleValueContainer()
					try container.encode(string)
				case .array(let array):
					var container = encoder.unkeyedContainer()
					for value in array {
						try container.encode(value)
					}
				case .dictionary(let dictionary):
					var container = encoder.container(keyedBy: AnyCodingKey.self)
					for (key, value) in dictionary {
						try container.encode(value, forKey: AnyCodingKey(stringValue: key)!)
					}
				}
			}
		}
		private var attributes: [String: Value] = [:]
		
		init(_ existingAttributes: [String: Any]) {
			func decodeAttribute(value: Any) -> Value? {
				if let value = value as? String {
					return .string(value)
				} else if let array = value as? [Any] {
					return .array(array.compactMap { decodeAttribute(value: $0) })
				} else if let dictionary = value as? [String: Any] {
					var mappedDictionary: [String: Value] = [:]
					for (key, value) in dictionary {
						if let mappedValue = decodeAttribute(value: value) {
							mappedDictionary[key] = mappedValue
						}
					}
					return .dictionary(mappedDictionary)
				} else {
					return nil
				}
			}
			for existingAttribute in existingAttributes {
				if let existingValue = decodeAttribute(value: existingAttribute.value) {
					attributes[existingAttribute.key] = existingValue
				}
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(attributes)
		}
	}
	
	enum CompatibilityVersion: String, Encodable {
		case xcode3_0 = "Xcode 3.0"
		case xcode3_2 = "Xcode 3.2"
		case xcode6_3 = "Xcode 6.3"
		case xcode8_0 = "Xcode 8.0"
		case xcode9_3 = "Xcode 9.3"
		case xcode_10 = "Xcode 10.0"
		case xcode_11 = "Xcode 11.0"
	}

	var attributes = Attributes([:])
	var buildConfigurationList: XCConfigurationList {
		didSet {
			buildConfigurationList.parent = self
		}
	}
	
	var compatibilityVersion: CompatibilityVersion = .xcode8_0
	var developmentRegion: String = "English"
	var hasScannedForEncodings: Bool = false
	var knownRegions: [String] = ["en"]
	public var mainGroup: PBXGroup {
		didSet {
			mainGroup.parent = self
		}
	}
	var productRefGroup: PBXGroup
	var projectDirPath: String?
	var projectReferences: Set<XCProjectReferenceInfo>?
	var projectRoot: String?
	public internal(set) var targets: [PBXTarget] = [] {
		didSet {
			targets.forEach { $0.parent = self }
		}
	}
	var packageReferences: [XCSwiftPackageReference]?
	
	var path: String?
	
	var projectDirectory: URL? {
		guard let path = path else { return nil }
		return URL(fileURLWithPath: (path as NSString).deletingLastPathComponent)
	}
	
	public internal(set) var objects: [PBXGlobalID: PBXObject] = [:]
	
	public required init(globalID: PBXGlobalID) {
		self.buildConfigurationList = XCConfigurationList()
		self.mainGroup = PBXGroup(globalID: PBXGlobalID())
		self.productRefGroup = PBXGroup(globalID: PBXGlobalID(), name: "Products")
		super.init(globalID: globalID)
		
		self.buildConfigurationList.parent = self
		self.mainGroup.parent = self
		self.productRefGroup.parent = self
		
		self.mainGroup.add(child: self.productRefGroup)
	}
	
	public convenience init() {
		self.init(globalID: PBXGlobalID())
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let attributes = plist[CodingKeys.attributes]?.dictionary,
			let buildConfigurationListID = PBXGlobalID(rawValue: plist[CodingKeys.buildConfigurationList]?.string),
			let buildConfigurationList = objectCache.object(for: buildConfigurationListID) as? XCConfigurationList,
			let compatibilityVersion = CompatibilityVersion(rawValue: plist[CodingKeys.compatibilityVersion]?.string ?? ""),
			let developmentRegion = plist[CodingKeys.developmentRegion]?.string,
			let hasScannedForEncodings = plist[CodingKeys.hasScannedForEncodings]?.string,
			let knownRegions = plist[CodingKeys.knownRegions]?.array,
			let mainGroup = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.mainGroup]?.string)) as? PBXGroup,
			let productRefGroup = objectCache.object(for: PBXGlobalID(rawValue: plist[CodingKeys.productRefGroup]?.string)) as? PBXGroup,
			let projectDirPath = plist[CodingKeys.projectDirPath]?.string,
			let projectRoot = plist[CodingKeys.projectRoot]?.string,
			let targets = plist[CodingKeys.targets]?.array
			else {
				fatalError()
		}
		
		self.attributes = Attributes(attributes)
		self.buildConfigurationList = buildConfigurationList
		self.compatibilityVersion = compatibilityVersion
		self.developmentRegion = developmentRegion
		self.hasScannedForEncodings = hasScannedForEncodings != "0"
		self.knownRegions = knownRegions
		self.mainGroup = mainGroup
		self.productRefGroup = productRefGroup
		self.projectDirPath = projectDirPath
		
		if let projectReferences = plist[CodingKeys.projectReferences]?.objectArray() {
			self.projectReferences = Set(projectReferences.map {
				XCProjectReferenceInfo(with: $0, objectCache: objectCache)
			})
		}
		
		if let packageReferences = plist[CodingKeys.packageReferences]?.array {
			self.packageReferences = packageReferences.map { PBXGlobalID(rawValue: $0) }.compactMap {
				objectCache.object(for: $0)
			}
		}
		
		self.projectRoot = projectRoot
		self.targets = targets.compactMap {
			let target: PBXTarget? = objectCache.object(for: PBXGlobalID(rawValue: $0))
			return target
		}
		
		self.objects = objectCache.objects
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		mainGroup.willMove(from: from)
		productRefGroup.willMove(from: from)
		targets.forEach {
			$0.willMove(from: from)
		}
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		mainGroup.didMove(to: to)
		productRefGroup.didMove(to: to)
		targets.forEach {
			$0.didMove(to: to)
		}
	}
	
	override var archiveComment: String {
		return "Project object"
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: buildConfigurationList)
		visitor.visit(object: mainGroup)
		visitor.visit(object: productRefGroup)
		targets.forEach {
			visitor.visit(object: $0)
		}
		projectReferences?.forEach {
			visitor.visit(object: $0.productGroup)
			visitor.visit(object: $0.projectReference)
		}
		packageReferences?.forEach {
			visitor.visit(object: $0)
		}
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(attributes, forKey: .attributes)
		try container.encode(buildConfigurationList, forKey: .buildConfigurationList)
		try container.encode(compatibilityVersion, forKey: .compatibilityVersion)
		try container.encode(developmentRegion, forKey: .developmentRegion)
		try container.encode(hasScannedForEncodings, forKey: .hasScannedForEncodings)
		try container.encode(knownRegions, forKey: .knownRegions)
		try container.encode(mainGroup, forKey: .mainGroup)
		try container.encodeIfPresent(packageReferences, forKey: .packageReferences)
		try container.encode(productRefGroup, forKey: .productRefGroup)
		try container.encodeIfPresent(projectDirPath, forKey: .projectDirPath)
		try container.encodeIfPresent(projectReferences?.sorted(by: \XCProjectReferenceInfo.projectReference.displayName, using: String.caseInsensitiveCompare), forKey: .projectReferences)
		try container.encodeIfPresent(projectRoot, forKey: .projectRoot)
		try container.encode(targets, forKey: .targets)
	}
	
	public var name: String? {
		guard let path = path else { return nil }
		var url = URL(fileURLWithPath: path)
		url.deletePathExtension()
		return url.lastPathComponent
	}
}
