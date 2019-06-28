//
//  PBXBuildRule.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-05.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXBuildRule: PBXObject {
	private enum CodingKeys: String, CodingKey {
		case compilerSpec
		case fileType
		case isEditable
		case outputFiles
		case script
	}
	var compilerSpec: String?
	var fileType: String?
	var isEditable: Bool = true
	var outputFiles: [String] = []
	var script: String?
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.compilerSpec = plist["compilerSpec"]?.string
		self.fileType = plist["fileType"]?.string
		self.isEditable = plist["isEditable"]?.bool ?? true
		self.outputFiles = plist["outputFiles"]?.array ?? []
		self.script = plist["script"]?.string
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(compilerSpec, forKey: .compilerSpec)
		try container.encodeIfPresent(fileType, forKey: .fileType)
		try container.encode(isEditable, forKey: .isEditable)
		try container.encode(outputFiles, forKey: .outputFiles)
		try container.encodeIfPresent(script, forKey: .script)
	}
}
