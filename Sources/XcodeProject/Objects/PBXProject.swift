//
//  PBXProject.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-19.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

public final class PBXProject: PBXObject, PBXContainer {
	var attributes: [String: Any] = [:]
	var buildConfigurationList: XCConfigurationList {
		didSet {
			buildConfigurationList.parent = self
		}
	}
	enum CompatibilityVersion: String {
		case xcode3_0 = "Xcode 3.0"
		case xcode3_2 = "Xcode 3.2"
		case xcode6_3 = "Xcode 6.3"
		case xcode8_0 = "Xcode 8.0"
		case xcode9_3 = "Xcode 9.3"
		case xcode_10 = "Xcode 10.0"
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
	var projectReferences: [(productGroup: PBXObject, projectRef: PBXFileReference)]?
	var projectRoot: String?
	public internal(set) var targets: [PBXTarget] = [] {
		didSet {
			targets.forEach { $0.parent = self }
		}
	}
	
	var path: String?
	
	var projectDirectory: URL? {
		guard let path = path else { return nil }
		return URL(fileURLWithPath: (path as NSString).deletingLastPathComponent)
	}
	
	public internal(set) var objects: [PBXObject.ID: PBXObject] = [:]
	
	public required init(globalID: PBXObject.ID) {
		self.buildConfigurationList = XCConfigurationList()
		self.mainGroup = PBXGroup(globalID: PBXObject.ID())
		self.productRefGroup = PBXGroup(globalID: PBXObject.ID(), name: "Products")
		super.init(globalID: globalID)
		
		self.buildConfigurationList.parent = self
		self.mainGroup.parent = self
		self.productRefGroup.parent = self
		
		self.mainGroup.add(child: self.productRefGroup)
	}
	
	public convenience init() {
		self.init(globalID: PBXObject.ID())
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let attributes = plist["attributes"]?.dictionary,
			let buildConfigurationListID = PBXObject.ID(rawValue: plist["buildConfigurationList"]?.string),
			let buildConfigurationList = objectCache.object(for: buildConfigurationListID) as? XCConfigurationList,
			let compatibilityVersion = CompatibilityVersion(rawValue: plist["compatibilityVersion"]?.string ?? ""),
			let developmentRegion = plist["developmentRegion"]?.string,
			let hasScannedForEncodings = plist["hasScannedForEncodings"]?.string,
			let knownRegions = plist["knownRegions"]?.array,
			let mainGroup = objectCache.object(for: PBXObject.ID(rawValue: plist["mainGroup"]?.string)) as? PBXGroup,
			let productRefGroup = objectCache.object(for: PBXObject.ID(rawValue: plist["productRefGroup"]?.string)) as? PBXGroup,
			let projectDirPath = plist["projectDirPath"]?.string,
			let projectRoot = plist["projectRoot"]?.string,
			let targets = plist["targets"]?.array
			else {
				fatalError()
		}
		
		self.attributes = attributes
		self.buildConfigurationList = buildConfigurationList
		self.compatibilityVersion = compatibilityVersion
		self.developmentRegion = developmentRegion
		self.hasScannedForEncodings = hasScannedForEncodings != "0"
		self.knownRegions = knownRegions
		self.mainGroup = mainGroup
		self.productRefGroup = productRefGroup
		self.projectDirPath = projectDirPath
		
		if let projectReferences = plist["projectReferences"]?.object as? [[String: String]] {
			self.projectReferences = projectReferences.compactMap { projectReference in
				guard
					let projectRefId = PBXObject.ID(rawValue: projectReference["ProjectRef"]),
					let projectRef = objectCache.object(for: projectRefId) as? PBXFileReference,
					
					let productGroupId = PBXObject.ID(rawValue: projectReference["ProductGroup"]),
					let productGroup = objectCache.object(for: productGroupId)
					else {
						return nil
				}
				return (productGroup: productGroup, projectRef: projectRef)
			}
		}
		
		self.projectRoot = projectRoot
		self.targets = targets.compactMap {
			let target: PBXTarget? = objectCache.object(for: PBXObject.ID(rawValue: $0))
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
			visitor.visit(object: $0.projectRef)
		}
	}
	
	override var plistRepresentation: [String: Any?] {
		var plist = super.plistRepresentation
		plist["attributes"] = attributes
		plist["buildConfigurationList"] = buildConfigurationList.plistID
		plist["compatibilityVersion"] = compatibilityVersion.rawValue
		plist["developmentRegion"] = developmentRegion
		plist["hasScannedForEncodings"] = hasScannedForEncodings
		plist["knownRegions"] = knownRegions
		plist["mainGroup"] = mainGroup.plistID
		plist["productRefGroup"] = productRefGroup.plistID
		plist["projectDirPath"] = projectDirPath
		plist["projectReferences"] = projectReferences?.map { return ["ProjectRef": $0.projectRef.plistID, "ProductGroup": $0.productGroup.plistID] }
		plist["projectRoot"] = projectRoot
		plist["targets"] = targets.map { $0.plistID }
		return plist
	}
	
	public var name: String? {
		guard let path = path else { return nil }
		var url = URL(fileURLWithPath: path)
		url.deletePathExtension()
		return url.lastPathComponent
	}
}
