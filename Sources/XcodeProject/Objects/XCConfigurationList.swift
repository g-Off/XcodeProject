//
//  XCConfigurationList.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class XCConfigurationList: PBXProjectItem {
	private enum CodingKeys: String, CodingKey {
		case buildConfigurations
		case defaultConfigurationIsVisible
		case defaultConfigurationName
	}
	
	var buildConfigurations: [XCBuildConfiguration] = [] {
		didSet {
			buildConfigurations.forEach { $0.parent = self }
		}
	}
	var defaultConfigurationIsVisible: Bool = false
	var defaultConfigurationName: String?
	
	public convenience init() {
		self.init(globalID: PBXGlobalID())
		
		self.buildConfigurations = [
			XCBuildConfiguration(name: "Debug", buildSettings: BuildSettings([:])),
			XCBuildConfiguration(name: "Release", buildSettings: BuildSettings([:])),
		]
		self.defaultConfigurationName = "Release"
	}
	
	override func willMove(from: PBXObject?) {
		super.willMove(from: from)
		buildConfigurations.forEach { $0.willMove(from: from) }
	}
	
	override func didMove(to: PBXObject?) {
		super.didMove(to: to)
		buildConfigurations.forEach { $0.didMove(to: to) }
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let buildConfigurations = PBXGlobalID.ids(from: plist[CodingKeys.buildConfigurations]?.array),
			let defaultConfigurationIsVisibleString = plist[CodingKeys.defaultConfigurationIsVisible]?.string
			else {
				fatalError()
		}
		
		self.buildConfigurations = buildConfigurations.compactMap { objectCache.object(for: $0) }
		self.defaultConfigurationIsVisible = Int(defaultConfigurationIsVisibleString) != 0
		self.defaultConfigurationName = plist[CodingKeys.defaultConfigurationName]?.string
	}
	
	override public func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		buildConfigurations.forEach {
			visitor.visit(object: $0)
		}
	}
	
	override var archiveComment: String {
		var comment = "Build configuration list"
		if let parent = parent, let name = (parent as? PBXContainer)?.name {
			comment += " for \(parent.isa) \"\(name)\""
		}
		return comment
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(buildConfigurations, forKey: .buildConfigurations)
		try container.encode(defaultConfigurationIsVisible, forKey: .defaultConfigurationIsVisible)
		try container.encodeIfPresent(defaultConfigurationName, forKey: .defaultConfigurationName)
	}
}
