//
//  PBXTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-26.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public class PBXTarget: PBXObject, PBXContainer {
	private enum CodingKeys: String, CodingKey {
		case buildConfigurationList
		case buildPhases
		case buildRules
		case dependencies
		case name
		case productName
		case productReference
	}

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
	public internal(set) var name: String?
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
			let buildConfigurationListID = PBXGlobalID(rawValue: plist["buildConfigurationList"]?.string),
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
		self.productReference = objectCache.object(for: PBXGlobalID(rawValue: plist["productReference"]?.string)) as? PBXFileReference
		self.buildConfigurationList = buildConfigurationList
		self.buildPhases = buildPhases.compactMap {
			return objectCache.object(for: PBXGlobalID(rawValue: $0)) as? PBXBuildPhase
		}
		self.buildRules = plist["buildRules"]?.array?.compactMap {
			return objectCache.object(for: PBXGlobalID(rawValue: $0)) as? PBXBuildRule
		}
		self.dependencies = dependencies.compactMap {
			return objectCache.object(for: PBXGlobalID(rawValue: $0)) as? PBXTargetDependency
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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(buildConfigurationList, forKey: .buildConfigurationList)
		try container.encodeIfPresent(buildPhases, forKey: .buildPhases)
		try container.encodeIfPresent(buildRules, forKey: .buildRules)
		try container.encode(dependencies, forKey: .dependencies)
		try container.encodeIfPresent(name, forKey: .name)
		try container.encodeIfPresent(productName, forKey: .productName)
		try container.encodeIfPresent(productReference, forKey: .productReference)
	}
}

extension PBXTarget {
	public var resourcesBuildPhase: PBXResourcesBuildPhase? {
		return buildPhases(type: PBXResourcesBuildPhase.self).first
	}
	
	private func buildPhases<T: PBXBuildPhase>(type: T.Type) -> [T] {
		return buildPhases.compactMap { $0 as? T }
	}
}
