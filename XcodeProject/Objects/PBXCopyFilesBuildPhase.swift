//
//  PBXCopyFilesBuildPhase.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

final class PBXCopyFilesBuildPhase: PBXBuildPhase {
	class override var defaultName: String {
		return "Copy Files"
	}
	
	enum Destination: Int8 {
		case absolutePath = 0
		case wrapper = 1
		case executables = 6
		case resources = 7 // default
		case frameworks = 10
		case sharedFrameworks = 11
		case sharedSupport = 12
		case plugins = 13
		case javaResources = 15
		case productsDirectory = 16
		
		init?(string: String?) {
			guard let string = string, let intValue = Int8(string) else { return nil }
			self.init(rawValue: intValue)
		}
	}
	
	var dstPath: String = ""
	var dstSubfolderSpec: Destination = .resources
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		guard let dstPath = plist["dstPath"]?.string else { fatalError() }
		self.dstPath = dstPath
		guard let dstSubfolderSpec = Destination(string: plist["dstSubfolderSpec"]?.string) else { fatalError() }
		self.dstSubfolderSpec = dstSubfolderSpec
	}
	
	override var plistRepresentation: [String : Any?] {
		var plist = super.plistRepresentation
		plist["dstPath"] = dstPath
		plist["dstSubfolderSpec"] = dstSubfolderSpec.rawValue
		return plist
	}
}
