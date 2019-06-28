//
//  PBXLegacyTarget.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-25.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXLegacyTarget: PBXTarget {
	private enum CodingKeys: String, CodingKey {
		case buildArgumentsString
		case buildToolPath
		case buildWorkingDirectory
		case passBuildSettingsInEnvironment
	}

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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(buildArguments, forKey: .buildArgumentsString)
		try container.encode(buildToolPath, forKey: .buildToolPath)
		try container.encode(buildWorkingDirectory, forKey: .buildWorkingDirectory)
		try container.encode(passBuildSettingsInEnvironment, forKey: .passBuildSettingsInEnvironment)
	}
}
