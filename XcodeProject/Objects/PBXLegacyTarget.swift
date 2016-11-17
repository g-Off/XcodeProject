//
//  PBXLegacyTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-25.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class PBXLegacyTarget: PBXTarget {
	var buildArguments: String?
	var buildToolPath: String?
	var buildWorkingDirectory: String?
	var passBuildSettingsInEnvironment: Bool = true
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		self.buildArguments = plist["buildArgumentsString"]?.string
		self.buildToolPath = plist["buildToolPath"]?.string
		self.buildWorkingDirectory = plist["buildWorkingDirectory"]?.string
		if let passBuildSettingsInEnvironment = plist["passBuildSettingsInEnvironment"]?.bool {
			self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironment
		}
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["buildArgumentsString"] = buildArguments
		plist["buildToolPath"] = buildToolPath
		plist["buildWorkingDirectory"] = buildWorkingDirectory
		plist["passBuildSettingsInEnvironment"] = passBuildSettingsInEnvironment
		return plist
	}
}
