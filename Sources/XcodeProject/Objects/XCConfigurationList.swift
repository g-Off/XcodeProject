//
//  XCConfigurationList.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class XCConfigurationList: PBXObject {
	var buildConfigurations: [XCBuildConfiguration] = [] {
		didSet {
			buildConfigurations.forEach { $0.parent = self }
		}
	}
	var defaultConfigurationIsVisible: Bool = false
	var defaultConfigurationName: String?
	
	public convenience init() {
		self.init(globalID: PBXObject.ID())
		
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
			let buildConfigurations = PBXObject.ID.ids(from: plist["buildConfigurations"]?.array),
			let defaultConfigurationIsVisibleString = plist["defaultConfigurationIsVisible"]?.string
			else {
				fatalError()
		}
		
		self.buildConfigurations = buildConfigurations.compactMap { objectCache.object(for: $0) }
		self.defaultConfigurationIsVisible = Int(defaultConfigurationIsVisibleString) != 0
		self.defaultConfigurationName = plist["defaultConfigurationName"]?.string
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
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["buildConfigurations"] = buildConfigurations.map { $0.plistID }
		plist["defaultConfigurationIsVisible"] = defaultConfigurationIsVisible
		plist["defaultConfigurationName"] = defaultConfigurationName
		return plist
	}
}
