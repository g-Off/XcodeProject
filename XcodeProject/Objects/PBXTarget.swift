//
//  PBXTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-26.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXTarget: PBXObject, PBXContainer {
	class var allowedBuildPhases: [PBXBuildPhase.Type] {
		return []
	}
	
	var buildConfigurationList: XCConfigurationList? {
		didSet {
			buildConfigurationList?.parent = self
		}
	}
	public internal(set) var buildPhases: [PBXBuildPhase] = [] {
		didSet {
			buildPhases.forEach { $0.parent = self }
		}
	}
	
	public func addBuildPhase<T: PBXBuildPhase>() -> T? {
		return nil
	}
	
	var buildRules: [PBXBuildRule]? {
		didSet {
			buildRules?.forEach { $0.parent = self }
		}
	}
	public internal(set) var dependencies: [PBXTargetDependency] = [] {
		didSet {
			dependencies.forEach { $0.parent = self }
		}
	}
	var name: String?
	var productName: String?
	var productReference: PBXFileReference? {
		didSet {
			productReference?.parent = self
		}
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		buildConfigurationList?.willMove(from: from)
		buildPhases.forEach { $0.willMove(from: from) }
		buildRules?.forEach { $0.willMove(from: from) }
		dependencies.forEach { $0.willMove(from: from) }
		productReference?.willMove(from: from)
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		buildConfigurationList?.didMove(to: to)
		buildPhases.forEach { $0.didMove(to: to) }
		buildRules?.forEach { $0.didMove(to: to) }
		dependencies.forEach { $0.didMove(to: to) }
		productReference?.didMove(to: to)
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let buildConfigurationListID = GlobalID(rawValue: plist["buildConfigurationList"]?.string),
			let buildConfigurationList = objectCache.object(for: buildConfigurationListID) as? XCConfigurationList,
			let buildPhases = plist["buildPhases"]?.array,
			let dependencies = plist["dependencies"]?.array,
			let name = plist["name"]?.string,
			let productName = plist["productName"]?.string
			else {
				fatalError()
		}
		self.name = name
		self.productName = productName
		self.productReference = objectCache.object(for: GlobalID(rawValue: plist["productReference"]?.string)) as? PBXFileReference
		self.buildConfigurationList = buildConfigurationList
		self.buildPhases = buildPhases.flatMap {
			return objectCache.object(for: GlobalID(rawValue: $0)) as? PBXBuildPhase
		}
		self.buildRules = plist["buildRules"]?.array?.flatMap {
			return objectCache.object(for: GlobalID(rawValue: $0)) as? PBXBuildRule
		}
		self.dependencies = dependencies.flatMap {
			return objectCache.object(for: GlobalID(rawValue: $0)) as? PBXTargetDependency
		}
	}
	
	override var archiveComment: String {
		return name ?? super.archiveComment
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: buildConfigurationList)
		buildPhases.forEach {
			visitor.visit(object: $0)
		}
		dependencies.forEach {
			visitor.visit(object: $0)
		}
		visitor.visit(object: productReference)
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["buildConfigurationList"] = buildConfigurationList?.plistID
		plist["buildPhases"] = buildPhases.map { $0.plistID }
		plist["buildRules"] = buildRules?.map { $0.plistID }
		plist["dependencies"] = dependencies.map { $0.plistID }
		plist["name"] = name
		plist["productName"] = productName
		plist["productReference"] = productReference?.plistID
		return plist
	}
}
