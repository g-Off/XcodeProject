//
//  PBXShellScriptBuildPhase.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-04.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXShellScriptBuildPhase: PBXBuildPhase {
	var inputPaths: [String] = []
	var outputPaths: [String] = []
	var shellPath: String?
	var shellScript: String?
	var showEnvVarsInLog: Bool?
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.inputPaths = plist["inputPaths"]?.array ?? []
		self.outputPaths = plist["outputPaths"]?.array ?? []
		self.shellPath = plist["shellPath"]?.string
		self.shellScript = plist["shellScript"]?.string
		self.showEnvVarsInLog = plist["showEnvVarsInLog"]?.bool
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["inputPaths"] = inputPaths
		plist["outputPaths"] = outputPaths
		plist["shellPath"] = shellPath
		plist["shellScript"] = shellScript
		plist["showEnvVarsInLog"] = showEnvVarsInLog
		return plist
	}
}
