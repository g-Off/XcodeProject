//
//  PBXCopyFilesBuildPhase.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

public final class PBXCopyFilesBuildPhase: PBXBuildPhase {
	private enum CodingKeys: String, CodingKey {
		case dstPath
		case dstSubfolderSpec
	}

	class override var defaultName: String {
		return "Copy Files"
	}
	
	enum Destination: Int8, Encodable {
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
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(dstPath, forKey: .dstPath)
		try container.encode(dstSubfolderSpec, forKey: .dstSubfolderSpec)
	}
}
