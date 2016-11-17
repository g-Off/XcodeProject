//
//  PBXBuildRule.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-05.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXBuildRule: PBXObject {
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
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["compilerSpec"] = compilerSpec
		plist["fileType"] = fileType
		plist["isEditable"] = isEditable
		plist["outputFiles"] = outputFiles
		plist["script"] = script
		return plist
	}
}
