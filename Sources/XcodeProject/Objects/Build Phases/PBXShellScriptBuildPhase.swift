//
//  PBXShellScriptBuildPhase.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-12-04.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXShellScriptBuildPhase: PBXBuildPhase {
	private enum CodingKeys: String, CodingKey {
		case inputPaths
		case outputPaths
		case inputFileListPaths
		case outputFileListPaths
		case shellPath
		case shellScript
		case showEnvVarsInLog
	}

	var inputPaths: [String] = []
	var outputPaths: [String] = []
	var inputFileListPaths: [String] = []
	var outputFileListPaths: [String] = []
	var shellPath: String?
	var shellScript: String?
	var showEnvVarsInLog: Bool?
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		self.inputPaths = plist[CodingKeys.inputPaths]?.array ?? []
		self.outputPaths = plist[CodingKeys.outputPaths]?.array ?? []
		self.inputFileListPaths = plist[CodingKeys.inputFileListPaths]?.array ?? []
		self.outputFileListPaths = plist[CodingKeys.outputFileListPaths]?.array ?? []
		self.shellPath = plist[CodingKeys.shellPath]?.string
		self.shellScript = plist[CodingKeys.shellScript]?.string
		self.showEnvVarsInLog = plist[CodingKeys.showEnvVarsInLog]?.bool
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(inputPaths, forKey: .inputPaths)
		try container.encode(outputPaths, forKey: .outputPaths)
		
		if encoder.objectVersion >= .xcode93 {
			try container.encode(inputFileListPaths, forKey: .inputFileListPaths)
			try container.encode(outputFileListPaths, forKey: .outputFileListPaths)
		}
		
		try container.encodeIfPresent(shellPath, forKey: .shellPath)
		try container.encodeIfPresent(shellScript, forKey: .shellScript)
		try container.encodeIfPresent(showEnvVarsInLog, forKey: .showEnvVarsInLog)
	}
}
