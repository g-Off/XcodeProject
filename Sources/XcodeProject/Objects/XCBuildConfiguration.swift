//
//  XCBuildConfiguration.swift
//  XcodeProject
//
//  Created by Geoffrey Foster on 2016-11-17.
//  Copyright © 2017 Geoffrey Foster. All rights reserved.
//

import Foundation

final class XCBuildConfiguration: PBXObject {
	private enum CodingKeys: String, CodingKey {
		case name
		case buildSettings
		case baseConfigurationReference
	}
	var name: String?
	var buildSettings = BuildSettings([:])
	var baseConfigurationReference: PBXFileReference?
	
	public convenience init(name: String, buildSettings: BuildSettings) {
		self.init(globalID: PBXGlobalID())
		
		self.name = name
		self.buildSettings = buildSettings
	}
	
	override func update(with plist: PropertyList, objectCache: ObjectCache) {
		super.update(with: plist, objectCache: objectCache)
		
		guard
			let name = plist[CodingKeys.name]?.string,
			let buildSettings = plist[CodingKeys.buildSettings]?.dictionary
			else {
				fatalError()
		}
		
		self.name = name
		self.buildSettings = BuildSettings(buildSettings)
		self.baseConfigurationReference = objectCache.object(for: plist[CodingKeys.baseConfigurationReference]?.globalID)
	}
	
	override var archiveComment: String {
		return name ?? super.archiveComment
	}
	
	override func visit(_ visitor: ObjectVisitor) {
		super.visit(visitor)
		visitor.visit(object: baseConfigurationReference)
	}
	
	public override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(name, forKey: .name)
		try container.encode(buildSettings, forKey: .buildSettings)
		try container.encodeIfPresent(baseConfigurationReference, forKey: .baseConfigurationReference)
	}
}

struct BuildSettings: Encodable {
	
//	CODE_SIGN_IDENTITY = "iPhone Developer";
//	"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
	
	// sdk=
	// *
	// iphoneos*
	// iphonesimulator*
	// macosx*
	// appletvos*
	// appletvsimulator*
	// watchos*
	// watchsimulator*
	
	enum SDK: CustomStringConvertible {
		case any
		case iphoneos(version: OperatingSystemVersion?)
		case iphonesimulator(version: OperatingSystemVersion?)
		case macosx(version: OperatingSystemVersion?)
		case appletvos(version: OperatingSystemVersion?)
		case appletvsimulator(version: OperatingSystemVersion?)
		case watchos(version: OperatingSystemVersion?)
		case watchsimulator(version: OperatingSystemVersion?)
		
		var description: String {
			func sdkString() -> String {
				func versionString(from osVersion: OperatingSystemVersion?) -> String {
					guard let osVersion = osVersion else {
						return ""
					}
					return "\(osVersion.majorVersion).\(osVersion.minorVersion)"
				}
				switch self {
				case .any:
					return "*"
				case .iphoneos(let version):
					return "iphoneos\(versionString(from: version))"
				case .iphonesimulator(let version):
					return "iphonesimulator\(versionString(from: version))"
				case .macosx(let version):
					return "macosx\(versionString(from: version))"
				case .appletvos(let version):
					return "appletvos\(versionString(from: version))"
				case .appletvsimulator(let version):
					return "appletvsimulator\(versionString(from: version))"
				case .watchos(let version):
					return "watchos\(versionString(from: version))"
				case .watchsimulator(let version):
					return "watchsimulator\(versionString(from: version))"
				}
			}
			return "[sdk=\(sdkString())]"
		}
	}
	
	enum Value: Encodable {
		case string(String)
		case array([String])
		
		init?(_ value: Any) {
			if let value = value as? String {
				self = .string(value)
			} else if let value = value as? [String] {
				self = .array(value)
			} else {
				return nil
			}
		}
		
		func encode(to encoder: Encoder) throws {
			switch self {
			case .string(let value):
				var container = encoder.singleValueContainer()
				try container.encode(value)
			case .array(let values):
				var container = encoder.unkeyedContainer()
				try values.forEach {
					try container.encode($0)
				}
			}
		}
	}
	
	var settings: [String: Value] = [:]
	
	init(_ settings: [String: Any]) {
		settings.forEach { (key, value) in
			if let value = Value(value) {
				self.settings[key] = value
			}
		}
	}
	
	subscript(setting: String, sdk: SDK?) -> Value? {
		var sdkString = ""
		if let sdk = sdk {
			sdkString = sdk.description
		}
		return settings[sdkString]
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: AnyCodingKey.self)
		for setting in settings {
			let key = AnyCodingKey(stringValue: setting.key)!
			try container.encode(setting.value, forKey: key)
		}
	}
}
